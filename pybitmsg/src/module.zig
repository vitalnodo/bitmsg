const std = @import("std");
const py = @import("pydust");
const bitmsg = @import("libbitmsg");
const standard1 = bitmsg.naive_pow.standardAverageProofOfWorkNonceTrialsPerByte;
const standard2 = bitmsg.naive_pow.standardPayloadLengthExtraBytes;

pub const Crypto = py.class(struct {
    const Self = @This();
    const MAXMSGSIZE = 256 * 1024;

    pub fn raw_encrypt(
        args: struct {
            K: py.PyObject,
            plaintext: py.PyObject,
            IV: py.PyObject,
            r: py.PyObject,
        },
    ) !py.PyBytes {
        var K = try args.K.getBuffer(py.PyBuffer.Flags.ND);
        defer K.release();
        var plaintext = try args.plaintext.getBuffer(py.PyBuffer.Flags.ND);
        defer plaintext.release();
        var IV = try args.IV.getBuffer(py.PyBuffer.Flags.ND);
        defer IV.release();
        var r = try args.r.getBuffer(py.PyBuffer.Flags.ND);
        defer r.release();

        if (K.len != 65) {
            return py.ValueError.raise("K size must be exactly 65 bytes");
        }
        if (IV.len != 16) {
            return py.ValueError.raise("IV size must be exactly 16 bytes");
        }
        if (r.len != 32) {
            return py.ValueError.raise("r size must be exactly 32 bytes");
        }

        const out = try py.allocator.alloc(u8, MAXMSGSIZE);
        defer py.allocator.free(out);

        const size = bitmsg.crypto.raw_encrypt(
            out,
            K.asSlice(u8)[0..65].*,
            plaintext.asSlice(u8),
            IV.asSlice(u8)[0..16].*,
            r.asSlice(u8)[0..32].*,
        ) catch |err| {
            return py.ValueError.raise(@errorName(err));
        };

        return py.PyBytes.create(out[0..size]);
    }

    pub fn encrypt(
        args: struct {
            K: py.PyObject,
            plaintext: py.PyObject,
        },
    ) !py.PyBytes {
        var K = try args.K.getBuffer(py.PyBuffer.Flags.ND);
        defer K.release();
        var plaintext = try args.plaintext.getBuffer(py.PyBuffer.Flags.ND);
        defer plaintext.release();

        if (K.len != 65) {
            return py.ValueError.raise("K size must be exactly 65 bytes");
        }

        const out = try py.allocator.alloc(u8, MAXMSGSIZE);
        defer py.allocator.free(out);

        const size = bitmsg.crypto.encrypt(
            out,
            K.asSlice(u8)[0..65].*,
            plaintext.asSlice(u8),
        ) catch |err| {
            return py.ValueError.raise(@errorName(err));
        };

        return py.PyBytes.create(out[0..size]);
    }

    pub fn raw_decrypt(
        args: struct {
            k: py.PyObject,
            IV: py.PyObject,
            R: py.PyObject,
            ciphertext: py.PyObject,
            MAC: py.PyObject,
        },
    ) !py.PyBytes {
        var k = try args.k.getBuffer(py.PyBuffer.Flags.ND);
        defer k.release();
        var IV = try args.IV.getBuffer(py.PyBuffer.Flags.ND);
        defer IV.release();
        var R = try args.R.getBuffer(py.PyBuffer.Flags.ND);
        defer R.release();
        var ciphertext = try args.ciphertext.getBuffer(py.PyBuffer.Flags.ND);
        defer ciphertext.release();
        var MAC = try args.MAC.getBuffer(py.PyBuffer.Flags.ND);
        defer MAC.release();

        if (k.len != 32) {
            return py.ValueError.raise("k size must be exactly 65 bytes");
        }
        if (IV.len != 16) {
            return py.ValueError.raise("IV size must be exactly 16 bytes");
        }
        if (R.len != 65) {
            return py.ValueError.raise("R size must be exactly 32 bytes");
        }
        if (MAC.len != 65) {
            return py.ValueError.raise("MAC size must be exactly 32 bytes");
        }

        const out = try py.allocator.alloc(u8, MAXMSGSIZE);
        defer py.allocator.free(out);

        const size = bitmsg.crypto.raw_decrypt(
            out,
            k.asSlice(u8)[0..32].*,
            IV.asSlice(u8)[0..16].*,
            R.asSlice(u8)[0..65].*,
            ciphertext.asSlice(u8),
            MAC.asSlice(u8)[0..32].*,
        ) catch |err| {
            return py.ValueError.raise(@errorName(err));
        };

        return py.PyBytes.create(out[0..size]);
    }

    pub fn decrypt(
        args: struct {
            k: py.PyObject,
            ciphertext: py.PyObject,
        },
    ) !py.PyBytes {
        var k = try args.k.getBuffer(py.PyBuffer.Flags.ND);
        defer k.release();
        var ciphertext = try args.ciphertext.getBuffer(py.PyBuffer.Flags.ND);
        defer ciphertext.release();

        if (k.len != 32) {
            return py.ValueError.raise("k size must be exactly 32 bytes");
        }

        const out = try py.allocator.alloc(u8, MAXMSGSIZE);
        defer py.allocator.free(out);

        const size = bitmsg.crypto.decrypt(
            out,
            k.asSlice(u8)[0..32].*,
            ciphertext.asSlice(u8),
        ) catch |err| {
            return py.ValueError.raise(@errorName(err));
        };

        return py.PyBytes.create(out[0..size]);
    }
});

pub const NaivePow = py.class(struct {
    const Self = @This();

    pub fn calc_target(
        args: struct {
            length: u64,
            TTL: u64,
            averageProofOfWorkNonceTrialsPerByte: u64 = standard1,
            payloadLengthExtraBytes: u64 = standard2,
        },
    ) u64 {
        return bitmsg.naive_pow.calc_target(
            args.length,
            args.TTL,
            .{
                .averageProofOfWorkNonceTrialsPerByte = args.averageProofOfWorkNonceTrialsPerByte,
                .payloadLengthExtraBytes = args.payloadLengthExtraBytes,
            },
        );
    }

    pub fn pow(
        args: struct {
            payload: py.PyObject,
            target: u64,
        },
    ) !u64 {
        var payload = try args.payload.getBuffer(py.PyBuffer.Flags.ND);
        return bitmsg.naive_pow.raw_naive_pow(
            payload.asSlice(u8),
            args.target,
        );
    }

    pub fn check(
        args: struct {
            payload: py.PyObject,
            nonce: u64,
            TTL: u64,
            averageProofOfWorkNonceTrialsPerByte: u64 = standard1,
            payloadLengthExtraBytes: u64 = standard2,
        },
    ) !bool {
        var payload = try args.payload.getBuffer(py.PyBuffer.Flags.ND);
        defer payload.release();
        return bitmsg.naive_pow.raw_check(
            payload.asSlice(u8),
            args.nonce,
            args.TTL,
            .{
                .averageProofOfWorkNonceTrialsPerByte = args.averageProofOfWorkNonceTrialsPerByte,
                .payloadLengthExtraBytes = args.payloadLengthExtraBytes,
            },
        );
    }
});

comptime {
    py.rootmodule(@This());
}
