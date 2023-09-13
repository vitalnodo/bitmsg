const std = @import("std");
const testing = std.testing;
const curve = std.crypto.ecc.Secp256k1;
const hash = std.crypto.hash.sha2.Sha512;
const HmacSha256 = std.crypto.auth.hmac.sha2.HmacSha256;
const CBC = @import("zig-cbc").CBC;
// So version 3 limits the objects to a maximum size of 256 KiB
const MAXMSGSIZE = 256 * 1024;

fn AES256CBC_encrypt(
    key: [32]u8,
    IV: [16]u8,
    plaintext: []const u8,
) ![]const u8 {
    const bounded = std.BoundedArray(u8, MAXMSGSIZE);
    const AES256CBC = CBC(std.crypto.core.aes.Aes256);
    const padded_length = AES256CBC.paddedLength(plaintext.len);
    var array = try bounded.init(padded_length);
    const z = AES256CBC.init(key);
    z.encrypt(array.buffer[0..padded_length], plaintext, IV);
    return array.buffer[0..padded_length];
}

fn AES256CBC_decrypt(
    key: [32]u8,
    IV: [16]u8,
    ciphertext: []const u8,
) ![]const u8 {
    const bounded = std.BoundedArray(u8, MAXMSGSIZE);
    const AES256CBC = CBC(std.crypto.core.aes.Aes256);
    const len = ciphertext.len - 1;
    var array = try bounded.init(len);
    const z = AES256CBC.init(key);
    try z.decrypt(array.buffer[0..len], ciphertext, IV);
    return array.buffer[0..len];
}

/// 1. The destination public key is called K.
/// 2. Generate 16 random bytes using a secure random number generator. Call them IV.
/// 3. Generate a new random EC key pair with private key called r and public key called R.
/// 4. Do an EC point multiply with public key K and private key r. This gives you public key P.
/// 5. Use the X component of public key P and calculate the SHA512 hash H.
/// 6. The first 32 bytes of H are called key_e and the last 32 bytes are called key_m.
/// 7. Pad the input text to a multiple of 16 bytes, in accordance to PKCS7.
/// 8. Encrypt the data with AES-256-CBC, using IV as initialization vector, key_e as encryption key and the padded input text as payload. Call the output cipher text.
/// 9. Calculate a 32 byte MAC with HMACSHA256, using key_m as salt and IV + R + cipher text as data. Call the output MAC.
/// The resulting data is: IV + R + cipher text + MAC
pub fn raw_encrypt(
    out: []u8,
    K: [65]u8,
    plaintext: []const u8,
    IV: [16]u8,
    r: [32]u8,
) !usize {
    std.mem.copy(u8, out[0..IV.len], &IV);
    const R = (try curve.basePoint.mul(r, .Big)).toUncompressedSec1();
    const R_for_MAC = blk: {
        var res: [70]u8 = undefined;
        std.mem.copy(u8, res[0..4], "\x02\xca\x00\x20");
        std.mem.copy(u8, res[4..36], R[1..33]);
        std.mem.copy(u8, res[36..38], "\x00\x20");
        std.mem.copy(u8, res[38..], R[33..65]);
        break :blk res;
    };
    std.mem.copy(u8, out[IV.len .. IV.len + R.len], &R);

    const P = try (try curve.fromSec1(&K)).mul(r, .Big);
    var H: [hash.digest_length]u8 = undefined;
    hash.hash(&P.affineCoordinates().x.toBytes(.Big), &H, .{});
    const key_e = H[0..32];
    const key_m = H[32..64];

    var ciphertext = try AES256CBC_encrypt(key_e.*, IV, plaintext);
    var ciphertext_slice = out[IV.len + R.len .. IV.len + R.len + ciphertext.len];
    std.mem.copy(u8, ciphertext_slice, ciphertext);

    var MAC = out[IV.len + R.len + ciphertext_slice.len .. IV.len + R.len + ciphertext_slice.len + 32];
    var zz = HmacSha256.init(key_m[0..32]);
    zz.update(&IV);
    zz.update(&R_for_MAC);
    zz.update(ciphertext_slice);
    zz.final(MAC[0..32]);

    return IV.len + R.len + ciphertext_slice.len + MAC.len;
}

pub fn encrypt(out: []u8, K: [65]u8, plaintext: []const u8) !usize {
    const IV = blk: {
        var buf: [16]u8 = undefined;
        std.crypto.random.bytes(&buf);
        break :blk buf;
    };
    const r = curve.scalar.random(.Big);
    return try raw_encrypt(out, K, plaintext, IV, r);
}

/// 1. The private key used to decrypt is called k.
/// 2. Do an EC point multiply with private key k and public key R. This gives you public key P.
/// 3. Use the X component of public key P and calculate the SHA512 hash H.
/// 4. The first 32 bytes of H are called key_e and the last 32 bytes are called key_m.
/// 5. Calculate MAC’ with HMACSHA256, using key_m as salt and IV + R + cipher text as data.
/// 6. Compare MAC with MAC’. If not equal, decryption will fail.
/// 7. Decrypt the cipher text with AES-256-CBC, using IV as initialization vector, key_e as decryption key and the cipher text as payload. The output is the padded input text. (No)
pub fn raw_decrypt(
    out: []u8,
    k: [32]u8,
    IV: [16]u8,
    R: [65]u8,
    ciphertext: []const u8,
    MAC: [32]u8,
) !usize {
    const R_for_MAC = blk: {
        var res: [70]u8 = undefined;
        std.mem.copy(u8, res[0..4], "\x02\xca\x00\x20");
        std.mem.copy(u8, res[4..36], R[1..33]);
        std.mem.copy(u8, res[36..38], "\x00\x20");
        std.mem.copy(u8, res[38..], R[33..65]);
        break :blk res;
    };
    const R_ = try curve.fromSec1(&R);
    const P = try curve.mul(R_, k, .Big);
    var H: [hash.digest_length]u8 = undefined;
    hash.hash(&P.affineCoordinates().x.toBytes(.Big), &H, .{});
    const key_e = H[0..32];
    const key_m = H[32..];

    var MAC_: [32]u8 = undefined;
    var zz = HmacSha256.init(key_m[0..32]);
    zz.update(&IV);
    zz.update(&R_for_MAC);
    zz.update(ciphertext);
    zz.final(MAC_[0..32]);
    if (!std.mem.eql(u8, &MAC, &MAC_)) {
        return error.DecryptionWillFail;
    }

    var plaintext = try AES256CBC_decrypt(key_e.*, IV, ciphertext);
    std.mem.copy(u8, out[0..plaintext.len], plaintext);

    return plaintext.len;
}

pub fn decrypt(out: []u8, k: [32]u8, raw_encrypted: []const u8) !usize {
    // IV + R + cipher text + MAC
    const IV = raw_encrypted[0..16].*;
    const R = raw_encrypted[16..81].*;
    const ciphertext = raw_encrypted[81 .. raw_encrypted.len - 32];
    const MAC = raw_encrypted[raw_encrypted.len - 32 ..][0..32].*;
    return try raw_decrypt(out, k, IV, R, ciphertext, MAC);
}

test "encrypt" {
    const IV = [_]u8{ 0xbd, 0xdb, 0x7c, 0x28, 0x29, 0xb0, 0x80, 0x38, 0x75, 0x30, 0x84, 0xa2, 0xf3, 0x99, 0x16, 0x81 };
    const K = [_]u8{ 0x04, 0x09, 0xd4, 0xe5, 0xc0, 0xab, 0x3d, 0x25, 0xfe, 0x04, 0x8c, 0x64, 0xc9, 0xda, 0x1a, 0x24, 0x2c, 0x7f, 0x19, 0x41, 0x7e, 0x95, 0x17, 0xcd, 0x26, 0x69, 0x50, 0xd7, 0x2c, 0x75, 0x57, 0x13, 0x58, 0x5c, 0x61, 0x78, 0xe9, 0x7f, 0xe0, 0x92, 0xfc, 0x89, 0x7c, 0x9a, 0x1f, 0x17, 0x20, 0xd5, 0x77, 0x0a, 0xe8, 0xea, 0xad, 0x2f, 0xa8, 0xfc, 0xbd, 0x08, 0xe9, 0x32, 0x4a, 0x5d, 0xde, 0x18, 0x57 };
    const r = [_]u8{ 0x5b, 0xe6, 0xfa, 0xcd, 0x94, 0x1b, 0x76, 0xe9, 0xd3, 0xea, 0xd0, 0x30, 0x29, 0xfb, 0xdb, 0x6b, 0x6e, 0x08, 0x09, 0x29, 0x3f, 0x7f, 0xb1, 0x97, 0xd0, 0xc5, 0x1f, 0x84, 0xe9, 0x6b, 0x8b, 0xa4 };
    const plaintext = "The quick brown fox jumps over the lazy dog.";
    var buf: [16 + 65 + 48 + 32]u8 = undefined;
    _ = try raw_encrypt(&buf, K, plaintext, IV, r);
    // IV
    try testing.expectEqualSlices(u8, &[_]u8{ 0xbd, 0xdb, 0x7c, 0x28, 0x29, 0xb0, 0x80, 0x38, 0x75, 0x30, 0x84, 0xa2, 0xf3, 0x99, 0x16, 0x81 }, buf[0..16]);
    // R
    try testing.expectEqualSlices(u8, &[_]u8{ 0x04, 0x02, 0x93, 0x21, 0x3d, 0xcf, 0x13, 0x88, 0xb6, 0x1c, 0x2a, 0xe5, 0xcf, 0x80, 0xfe, 0xe6, 0xff, 0xff, 0xc0, 0x49, 0xa2, 0xf9, 0xfe, 0x73, 0x65, 0xfe, 0x38, 0x67, 0x81, 0x3c, 0xa8, 0x12, 0x92, 0xdf, 0x94, 0x68, 0x6c, 0x6a, 0xfb, 0x56, 0x5a, 0xc6, 0x14, 0x9b, 0x15, 0x3d, 0x61, 0xb3, 0xb2, 0x87, 0xee, 0x2c, 0x7f, 0x99, 0x7c, 0x14, 0x23, 0x87, 0x96, 0xc1, 0x2b, 0x43, 0xa3, 0x86, 0x5a }, buf[16..81]);
    // ciphertext
    try testing.expectEqualSlices(u8, &[_]u8{ 0x64, 0x20, 0x3d, 0x5b, 0x24, 0x68, 0x8e, 0x25, 0x47, 0xbb, 0xa3, 0x45, 0xfa, 0x13, 0x9a, 0x5a, 0x1d, 0x96, 0x22, 0x20, 0xd4, 0xd4, 0x8a, 0x0c, 0xf3, 0xb1, 0x57, 0x2c, 0x0d, 0x95, 0xb6, 0x16, 0x43, 0xa6, 0xf9, 0xa0, 0xd7, 0x5a, 0xf7, 0xea, 0xcc, 0x1b, 0xd9, 0x57, 0x14, 0x7b, 0xf7, 0x23 }, buf[81..129]);
    // MAC
    try testing.expectEqualSlices(u8, &[_]u8{ 0xf2, 0x52, 0x6d, 0x61, 0xb4, 0x85, 0x1f, 0xb2, 0x34, 0x09, 0x86, 0x38, 0x26, 0xfd, 0x20, 0x61, 0x65, 0xed, 0xc0, 0x21, 0x36, 0x8c, 0x79, 0x46, 0x57, 0x1c, 0xea, 0xd6, 0x90, 0x46, 0xe6, 0x19 }, buf[129..]);
}

test "decrypt" {
    const plaintext =
        \\I didn't find private key for the previos message. 
        \\So here is my message.
    ;
    const private = curve.scalar.random(.Big);
    const public = (try curve.basePoint.mul(private, .Big)).toUncompressedSec1();
    var buf: [256]u8 = undefined;
    const encr_len = try encrypt(&buf, public, plaintext);
    const encrypted = buf[0..encr_len];

    var buf1: [256]u8 = undefined;
    const decr_len = try decrypt(&buf1, private, encrypted);
    const decrypted = buf1[0..decr_len];
    try testing.expectStringStartsWith(decrypted, plaintext);
}
