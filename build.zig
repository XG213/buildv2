const std = @import("std");
const builtin = @import("builtin");

const pkgs = struct {
    const network = std.build.Pkg {
        .name = "network",
        .source = .{ .path = "network/network.zig" },
    };
};

pub fn build(b: *std.build.Builder) void {

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("Classic-Server", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackage(pkgs.network);
    exe.addIncludePath("./zlib/");
    exe.addCSourceFiles(&[_][]const u8{
        "zlib/adler32.c",
        "zlib/crc32.c",
        "zlib/deflate.c",
        "zlib/gzclose.c",
        "zlib/gzlib.c",
        "zlib/gzread.c",
        "zlib/gzwrite.c",
        "zlib/infback.c",
        "zlib/inffast.c",
        "zlib/inflate.c",
        "zlib/inftrees.c",
        "zlib/trees.c",
        "zlib/uncompr.c",
        "zlib/zutil.c",
    }, &[_][]const u8{
        "-Wall",
        "-Werror",
    });
    exe.linkLibC();
    exe.use_stage1 = true;
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the server");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);
}
