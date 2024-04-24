const std = @import("std");
const testing = std.testing;
pub const crypto = @import("crypto.zig");
pub const naive_pow = @import("naive_pow.zig");

pub export fn crypto_raw_encrypt(
    _out: [*]u8,
    _out_len: usize,
    _K: [*c]u8,
    _plaintext: [*c]u8,
    _IV: [*c]u8,
    _r: [*c]u8,
) callconv(.C) usize {
    var out = _out[0.._out_len];
    const K: [65]u8 = _K[0..65].*;
    const plaintext = std.mem.span(_plaintext);
    const IV: [16]u8 = _IV[0..16].*;
    const r: [32]u8 = _r[0..32].*;
    return crypto.raw_encrypt(out, K, plaintext, IV, r) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return 0;
    };
}

pub export fn crypto_raw_decrypt(
    _out: [*]u8,
    _out_len: usize,
    _k: [*c]u8,
    _IV: [*c]u8,
    _R: [*c]u8,
    _ciphertext: [*c]u8,
    _MAC: [*c]u8,
) callconv(.C) usize {
    var out = _out[0.._out_len];
    const k: [32]u8 = _k[0..32].*;
    const ciphertext = std.mem.span(_ciphertext);
    const IV: [16]u8 = _IV[0..16].*;
    const R: [65]u8 = _R[0..65].*;
    const MAC: [32]u8 = _MAC[0..32].*;
    return crypto.raw_decrypt(out, k, IV, R, ciphertext, MAC) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return 0;
    };
}

pub export fn naive_pow_calc_target(
    length: u64,
    TTL: u64,
    nonceTrialsPerByte: u64,
    payloadLengthExtraBytes: u64,
) callconv(.C) usize {
    var o: naive_pow.POWOptions = .{};
    if (nonceTrialsPerByte != 0) {
        o.averageProofOfWorkNonceTrialsPerByte = nonceTrialsPerByte;
    }
    if (payloadLengthExtraBytes != 0) {
        o.payloadLengthExtraBytes = payloadLengthExtraBytes;
    }
    return naive_pow.calc_target(length, TTL, o);
}

pub export fn naive_pow_raw_naive_pow(
    _payload: [*]u8,
    _payload_len: usize,
    target: u64,
) callconv(.C) u64 {
    const payload = _payload[0.._payload_len];
    return naive_pow.raw_naive_pow(payload, target);
}

pub export fn naive_pow_raw_check(
    _payload: [*]u8,
    _payload_len: usize,
    nonce: u64,
    TTL: u64,
    nonceTrialsPerByte: u64,
    payloadLengthExtraBytes: u64,
) callconv(.C) bool {
    const payload = _payload[0.._payload_len];
    var o: naive_pow.POWOptions = .{};
    if (nonceTrialsPerByte != 0) {
        o.averageProofOfWorkNonceTrialsPerByte = nonceTrialsPerByte;
    }
    if (payloadLengthExtraBytes != 0) {
        o.payloadLengthExtraBytes = payloadLengthExtraBytes;
    }
    return naive_pow.raw_check(payload, nonce, TTL, o);
}

test {
    std.testing.refAllDecls(@This());
}
