const std = @import("std");
const py = @import("./pydust.build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const pydust = py.addPydust(b, .{});
    const module = pydust.addPythonModule(.{
        .name = "pybitmsg.bitmsg",
        .root_source_file = .{ .path = "src/module.zig" },
        .main_pkg_path = .{ .path = "src/" },
        .limited_api = true,
        .target = target,
        .optimize = optimize,
    });

    const libbitmsg = b.anonymousDependency(
        "libbitmsg",
        @import("libbitmsg/build.zig"),
        .{
            .target = target,
            .optimize = optimize,
        },
    );
    module.library_step.addModule("libbitmsg", libbitmsg.module("libbitmsg"));
    module.test_step.addModule("libbitmsg", libbitmsg.module("libbitmsg"));
}
