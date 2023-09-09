const py = @cImport({
    @cDefine("PY_SSIZE_T_CLEAN", "1");
    @cInclude("Python.h");
});
const std = @import("std");
const crypto = @import("crypto.zig");
const naive_pow = @import("naive_pow.zig");

const PyObject = py.PyObject;
const PyMethodDef = py.PyMethodDef;
const PyModuleDef = py.PyModuleDef;
const PyModuleDef_Base = py.PyModuleDef_Base;
const Py_BuildValue = py.Py_BuildValue;
const PyModule_Create = py.PyModule_Create;
const METH_NOARGS = py.METH_NOARGS;
const PyArg_ParseTuple = py.PyArg_ParseTuple;
const PyLong_FromLong = py.PyLong_FromLong;

fn encrypt(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) ?[*]PyObject {
    _ = self;
    var K = std.mem.zeroInit(py.Py_buffer, .{});
    var plaintext = std.mem.zeroInit(py.Py_buffer, .{});
    if (!(py.PyArg_ParseTuple(args, "y*s*", &K, &plaintext) != 0)) return null;

    if (K.len != 65) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "Key size must be exactly 65 bytes",
        );
        return null;
    }

    var K_actual = @as([*]u8, @ptrCast(K.buf.?))[0..65];
    var plaintext_actual = @as(
        [*]u8,
        @ptrCast(plaintext.buf.?),
    )[0..@as(usize, @intCast(plaintext.len))];
    var out_ptr_a = py.PyMem_RawMalloc(256 * 1024);
    var out_ptr = @as([*]u8, @ptrCast(out_ptr_a.?))[0 .. 256 * 1024];
    var out_len = crypto.encrypt(out_ptr, K_actual.*, plaintext_actual) catch 0;
    var res = Py_BuildValue("y#", out_ptr, out_len);

    py.PyBuffer_Release(&K);
    py.PyBuffer_Release(&plaintext);
    py.PyMem_RawFree(out_ptr_a);
    return res;
}

fn decrypt(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) ?[*]PyObject {
    _ = self;
    var k = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&k);
    var raw_encrypted = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&raw_encrypted);
    if (!(py.PyArg_ParseTuple(
        args,
        "y*s*",
        &k,
        &raw_encrypted,
    ) != 0)) return null;

    if (k.len != 32) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "k size must be exactly 32 bytes",
        );
        return null;
    }

    var k_actual = @as([*]u8, @ptrCast(k.buf.?))[0..32];
    var raw_encrypted_actual = @as(
        [*]u8,
        @ptrCast(raw_encrypted.buf.?),
    )[0..@as(usize, @intCast(raw_encrypted.len))];

    var out_ptr = py.PyMem_RawMalloc(256 * 1024);
    defer py.PyMem_RawFree(out_ptr);
    var out_slice = @as([*]u8, @ptrCast(out_ptr.?))[0 .. 256 * 1024];
    var out_len = crypto.decrypt(
        out_slice,
        k_actual.*,
        raw_encrypted_actual,
    ) catch 0;
    return Py_BuildValue("y#", out_ptr, out_len);
}

fn raw_encrypt(
    self: [*c]PyObject,
    args: [*c]PyObject,
) callconv(.C) ?[*]PyObject {
    _ = self;
    var K = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&K);
    var plaintext = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&plaintext);
    var IV = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&IV);
    var r = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&r);

    if (!(py.PyArg_ParseTuple(
        args,
        "y*s*y*y*",
        &K,
        &plaintext,
        &IV,
        &r,
    ) != 0)) return null;

    if (K.len != 65) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "K size must be exactly 65 bytes",
        );
        return null;
    }
    if (IV.len != 16) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "IV size must be exactly 16 bytes",
        );
        return null;
    }
    if (r.len != 32) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "r size must be exactly 32 bytes",
        );
        return null;
    }

    var K_actual = @as([*]u8, @ptrCast(K.buf.?))[0..65];
    var plaintext_actual = @as(
        [*]u8,
        @ptrCast(plaintext.buf.?),
    )[0..@as(usize, @intCast(plaintext.len))];
    var IV_actual = @as([*]u8, @ptrCast(IV.buf.?))[0..16];
    var r_actual = @as([*]u8, @ptrCast(r.buf.?))[0..32];

    var out_ptr = py.PyMem_RawMalloc(256 * 1024);
    defer py.PyMem_RawFree(out_ptr);
    var out_slice = @as([*]u8, @ptrCast(out_ptr.?))[0 .. 256 * 1024];
    var out_len = crypto.raw_encrypt(
        out_slice,
        K_actual.*,
        plaintext_actual,
        IV_actual.*,
        r_actual.*,
    ) catch 0;
    return Py_BuildValue("y#", out_ptr, out_len);
}

fn raw_decrypt(
    self: [*c]PyObject,
    args: [*c]PyObject,
) callconv(.C) ?[*]PyObject {
    _ = self;
    var k = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&k);
    var IV = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&IV);
    var R = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&R);
    var ciphertext = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&ciphertext);
    var MAC = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&MAC);
    if (!(py.PyArg_ParseTuple(
        args,
        "y*y*y*s*y*",
        &k,
        &IV,
        &R,
        &ciphertext,
        &MAC,
    ) != 0)) return null;

    if (k.len != 32) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "k size must be exactly 32 bytes",
        );
        return null;
    }
    if (IV.len != 16) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "IV size must be exactly 16 bytes",
        );
        return null;
    }
    if (R.len != 65) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "R size must be exactly 65 bytes",
        );
        return null;
    }
    if (MAC.len != 32) {
        py.PyErr_SetString(
            py.PyExc_ValueError,
            "MAC size must be exactly 65 bytes",
        );
        return null;
    }

    var k_actual = @as([*]u8, @ptrCast(k.buf.?))[0..32];
    var IV_actual = @as([*]u8, @ptrCast(IV.buf.?))[0..16];
    var R_actual = @as([*]u8, @ptrCast(R.buf.?))[0..65];
    var ciphertext_actual = @as(
        [*]u8,
        @ptrCast(ciphertext.buf.?),
    )[0..@as(usize, @intCast(ciphertext.len))];
    var MAC_actual = @as([*]u8, @ptrCast(MAC.buf.?))[0..32];

    var out_ptr = py.PyMem_RawMalloc(256 * 1024);
    defer py.PyMem_RawFree(out_ptr);
    var out_slice = @as([*]u8, @ptrCast(out_ptr.?))[0 .. 256 * 1024];

    var out_len = crypto.raw_decrypt(
        out_slice,
        k_actual.*,
        IV_actual.*,
        R_actual.*,
        ciphertext_actual,
        MAC_actual.*,
    ) catch 0;
    return Py_BuildValue("y#", out_ptr, out_len);
}

fn naive_pow_calc_target(
    self: [*c]PyObject,
    args: [*c]PyObject,
) callconv(.C) ?[*]PyObject {
    _ = self;
    var length: u64 = 0;
    var TTL: u64 = 0;
    var POWOptions = naive_pow.POWOptions{};
    if (!(py.PyArg_ParseTuple(
        args,
        "kk|kk",
        &length,
        &TTL,
        &POWOptions.averageProofOfWorkNonceTrialsPerByte,
        &POWOptions.payloadLengthExtraBytes,
    ) != 0)) return null;
    const target = naive_pow.calc_target(
        length,
        TTL,
        POWOptions,
    );
    return Py_BuildValue("k", @as(u64, target));
}

fn naive_pow_raw_naive_pow(
    self: [*c]PyObject,
    args: [*c]PyObject,
) callconv(.C) ?[*]PyObject {
    _ = self;
    var payload = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&payload);
    var target: u64 = 0;
    if (!(py.PyArg_ParseTuple(
        args,
        "s*k",
        &payload,
        &target,
    ) != 0)) return null;
    var payload_actual = @as(
        [*]u8,
        @ptrCast(payload.buf.?),
    )[0..@as(usize, @intCast(payload.len))];
    const nonce = naive_pow.raw_naive_pow(payload_actual, target);
    return Py_BuildValue("k", @as(u64, nonce));
}

fn naive_pow_raw_check(
    self: [*c]PyObject,
    args: [*c]PyObject,
) callconv(.C) ?[*]PyObject {
    _ = self;
    var payload = std.mem.zeroInit(py.Py_buffer, .{});
    defer py.PyBuffer_Release(&payload);
    var nonce: u64 = 0;
    var TTL: u64 = 0;
    var POWOptions = naive_pow.POWOptions{};
    if (!(py.PyArg_ParseTuple(
        args,
        "s*kk|kk",
        &payload,
        &nonce,
        &TTL,
        &POWOptions.averageProofOfWorkNonceTrialsPerByte,
        &POWOptions.payloadLengthExtraBytes,
    ) != 0)) return null;
    var payload_actual = @as(
        [*]u8,
        @ptrCast(payload.buf.?),
    )[0..@as(usize, @intCast(payload.len))];
    const check = naive_pow.raw_check(
        payload_actual,
        nonce,
        TTL,
        POWOptions,
    );
    const res = if (check) py.Py_True else py.Py_False;
    return Py_BuildValue("O", res);
}

var Methods = [_]PyMethodDef{
    PyMethodDef{
        .ml_name = "encrypt",
        .ml_meth = encrypt,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "raw_encrypt",
        .ml_meth = raw_encrypt,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "decrypt",
        .ml_meth = decrypt,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "raw_decrypt",
        .ml_meth = raw_decrypt,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "naive_pow_calc_target",
        .ml_meth = naive_pow_calc_target,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "naive_pow_raw_naive_pow",
        .ml_meth = naive_pow_raw_naive_pow,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "naive_pow_raw_check",
        .ml_meth = naive_pow_raw_check,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = null,
        .ml_meth = null,
        .ml_flags = 0,
        .ml_doc = null,
    },
};

var module = PyModuleDef{
    .m_base = PyModuleDef_Base{
        .ob_base = PyObject{
            .ob_refcnt = 1,
            .ob_type = null,
        },
        .m_init = null,
        .m_index = 0,
        .m_copy = null,
    },
    .m_name = "native",
    .m_doc = null,
    .m_size = -1,
    .m_methods = &Methods,
    .m_slots = null,
    .m_traverse = null,
    .m_clear = null,
    .m_free = null,
};

pub export fn PyInit_native() [*]PyObject {
    return PyModule_Create(&module);
}
