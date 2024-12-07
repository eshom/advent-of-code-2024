const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day1 = b.addExecutable(.{
        .name = "day1",
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(day1);

    const run_day1 = b.addRunArtifact(day1);
    run_day1.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_day1.addArgs(args);
    }

    const run_step_day1 = b.step("day1", "Run day1");
    run_step_day1.dependOn(&run_day1.step);
}
