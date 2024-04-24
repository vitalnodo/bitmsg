import ctypes

c_char_p = ctypes.c_char_p
c_size_t = ctypes.c_size_t
c_uint64 = ctypes.c_uint64

lib = ctypes.CDLL("./libbitmsg/zig-out/lib/libbitmsg.so")
b = ctypes.create_string_buffer

IV = bytes(
    [
        0xBD,
        0xDB,
        0x7C,
        0x28,
        0x29,
        0xB0,
        0x80,
        0x38,
        0x75,
        0x30,
        0x84,
        0xA2,
        0xF3,
        0x99,
        0x16,
        0x81,
    ]
)
K = bytes(
    [
        0x04,
        0x09,
        0xD4,
        0xE5,
        0xC0,
        0xAB,
        0x3D,
        0x25,
        0xFE,
        0x04,
        0x8C,
        0x64,
        0xC9,
        0xDA,
        0x1A,
        0x24,
        0x2C,
        0x7F,
        0x19,
        0x41,
        0x7E,
        0x95,
        0x17,
        0xCD,
        0x26,
        0x69,
        0x50,
        0xD7,
        0x2C,
        0x75,
        0x57,
        0x13,
        0x58,
        0x5C,
        0x61,
        0x78,
        0xE9,
        0x7F,
        0xE0,
        0x92,
        0xFC,
        0x89,
        0x7C,
        0x9A,
        0x1F,
        0x17,
        0x20,
        0xD5,
        0x77,
        0x0A,
        0xE8,
        0xEA,
        0xAD,
        0x2F,
        0xA8,
        0xFC,
        0xBD,
        0x08,
        0xE9,
        0x32,
        0x4A,
        0x5D,
        0xDE,
        0x18,
        0x57,
    ]
)
r = bytes(
    [
        0x5B,
        0xE6,
        0xFA,
        0xCD,
        0x94,
        0x1B,
        0x76,
        0xE9,
        0xD3,
        0xEA,
        0xD0,
        0x30,
        0x29,
        0xFB,
        0xDB,
        0x6B,
        0x6E,
        0x08,
        0x09,
        0x29,
        0x3F,
        0x7F,
        0xB1,
        0x97,
        0xD0,
        0xC5,
        0x1F,
        0x84,
        0xE9,
        0x6B,
        0x8B,
        0xA4,
    ]
)
plaintext = b"The quick brown fox jumps over the lazy dog."
c = 16 + 65 + 48 + 32
s = ctypes.create_string_buffer(c)
lib.crypto_raw_encrypt.argtypes = [
    c_char_p,
    c_size_t,
    c_char_p,
    c_char_p,
    c_char_p,
    c_char_p,
]
lib.crypto_raw_encrypt(s, c, b(K), b(plaintext), b(IV), b(r))
expected = "bddb7c2829b08038753084a2f3991681040293213dcf1388b61c2ae5cf80fee6ffffc049a2f9fe7365fe3867813ca81292df94686c6afb565ac6149b153d61b3b287ee2c7f997c14238796c12b43a3865a64203d5b24688e2547bba345fa139a5a1d962220d4d48a0cf3b1572c0d95b61643a6f9a0d75af7eacc1bd957147bf723f2526d61b4851fb23409863826fd206165edc021368c7946571cead69046e619"
assert s.value.hex() == expected

lib.naive_pow_calc_target.argtypes = [
    c_uint64,
    c_uint64,
    c_uint64,
    c_uint64,
    c_uint64,
]
lib.naive_pow_calc_target.restype = c_uint64
msg = b"hello"
TTL = 500
target = lib.naive_pow_calc_target(len(msg), 500, 0, 0, 0)
assert target == 18085043209519
lib.naive_pow_raw_naive_pow.argtypes = [c_char_p, c_size_t, c_uint64]
lib.naive_pow_raw_naive_pow.restype = c_uint64
actual_pow = lib.naive_pow_raw_naive_pow(msg, len(msg), target)
assert actual_pow == 585273
lib.naive_pow_raw_check.argtypes = [
    c_char_p,
    c_size_t,
    c_uint64,
    c_uint64,
    c_uint64,
    c_uint64,
]
lib.naive_pow_raw_check.restype = ctypes.c_bool
assert lib.naive_pow_raw_check(msg, len(msg), actual_pow, TTL, 0, 0) == True
