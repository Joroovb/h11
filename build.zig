const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const http_mod = b.dependency("http", .{}).module("http");

    b.addModule(.{
        .name = "h11",
        .source_file = .{ .path = "src/main.zig" },
        .dependencies = &.{
            .{
                .name = "http",
                .module = http_mod,
            },
        },
    });

    tests(b, target, optimize);
    clean(b);
}

fn tests(b: *std.Build, target: std.zig.CrossTarget, mode: std.builtin.OptimizeMode) void {
    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = mode,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn clean(b: *std.Build) void {
    const cmd = b.addSystemCommand(&[_][]const u8{
        "rm",
        "-rf",
        "zig-out",
        "zig-cache",
    });

    const clean_step = b.step("clean", "Remove project artifacts");
    clean_step.dependOn(&cmd.step);
}
