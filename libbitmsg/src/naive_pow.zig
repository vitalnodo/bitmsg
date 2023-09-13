const std = @import("std");
const testing = std.testing;
const hash = std.crypto.hash.sha2.Sha512;

pub const standardAverageProofOfWorkNonceTrialsPerByte = 1000;
pub const standardPayloadLengthExtraBytes = 1000;

pub const POWOptions = struct {
    averageProofOfWorkNonceTrialsPerByte: u64 = standardAverageProofOfWorkNonceTrialsPerByte,
    payloadLengthExtraBytes: u64 = standardPayloadLengthExtraBytes,
};

pub fn calc_target(length: u64, TTL: u64, options: POWOptions) u64 {
    const payloadLength = length + 8;
    const nonceTrialsPerByte = options.averageProofOfWorkNonceTrialsPerByte;
    const payloadLengthExtraBytes = options.payloadLengthExtraBytes;

    const divisor = nonceTrialsPerByte *
        (payloadLength + payloadLengthExtraBytes +
        ((TTL * (payloadLength + payloadLengthExtraBytes)) / (1 << 16)));

    var target = @as(u128, @intCast((1 << 64))) / divisor;
    return @as(u64, @intCast(target));
}

pub fn raw_naive_pow(payload: []const u8, target: u64) u64 {
    var initial_hash: [hash.digest_length]u8 = undefined;
    hash.hash(payload, &initial_hash, .{});
    var trial_value: u64 = std.math.maxInt(u64);
    var nonce: u64 = 0;
    while (trial_value > target) {
        nonce += 1;
        var nonce_bytes: [8]u8 = undefined;
        std.mem.writeIntBig(u64, &nonce_bytes, nonce);
        var h = hash.init(.{});
        var result_hash: [hash.digest_length]u8 = undefined;
        h.update(&nonce_bytes);
        h.update(&initial_hash);
        h.final(&result_hash);
        hash.hash(&result_hash, &result_hash, .{});
        trial_value = std.mem.readIntBig(u64, result_hash[0..8]);
    }
    return nonce;
}

pub fn raw_check(
    payload: []const u8,
    nonce: u64,
    TTL: u64,
    options: POWOptions,
) bool {
    var nonce_bytes: [8]u8 = undefined;
    std.mem.writeIntBig(u64, &nonce_bytes, nonce);
    const target = calc_target(payload.len, TTL, options);
    var initial_hash: [hash.digest_length]u8 = undefined;
    hash.hash(payload, &initial_hash, .{});
    var h = hash.init(.{});
    var result_hash: [hash.digest_length]u8 = undefined;
    h.update(&nonce_bytes);
    h.update(&initial_hash);
    h.final(&result_hash);
    hash.hash(&result_hash, &result_hash, .{});
    const POW_value = std.mem.readIntBig(u64, result_hash[0..8]);
    return POW_value <= target;
}

test {
    const msg = "hello";
    const TTL = 500;
    const target = calc_target(msg.len, TTL, .{});
    const res = raw_naive_pow(msg, target);
    const check = raw_check(msg, res, TTL, .{});

    try testing.expectEqual(@as(u64, 18085043209519), target);
    try testing.expectEqual(@as(u64, 585273), res);
    try testing.expectEqual(true, check);
}
