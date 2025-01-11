const std = @import("std");

fn dayExecuteable(
    b: *std.Build,
    day_number: comptime_int,
    opts: struct { t: std.Build.ResolvedTarget, o: std.builtin.OptimizeMode },
) *std.Build.Step.Compile {
    const day_str = std.fmt.comptimePrint("day{d}", .{day_number});
    return b.addExecutable(.{
        .name = day_str,
        .root_source_file = b.path("src/" ++ day_str ++ ".zig"),
        .target = opts.t,
        .optimize = opts.o,
    });
}

fn runDay(b: *std.Build, exe: *std.Build.Step.Compile, name: []const u8, desc: []const u8) *std.Build.Step {
    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run.addArgs(args);
    }
    const run_step = b.step(name, desc);
    run_step.dependOn(&run.step);
    return run_step;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day1 = dayExecuteable(b, 1, .{ .t = target, .o = optimize });
    b.installArtifact(day1);
    _ = runDay(b, day1, "day1", "Run day1");

    const day2 = dayExecuteable(b, 2, .{ .t = target, .o = optimize });
    b.installArtifact(day2);
    _ = runDay(b, day2, "day2", "Run day2");

    const day3 = dayExecuteable(b, 3, .{ .t = target, .o = optimize });
    b.installArtifact(day3);
    _ = runDay(b, day3, "day3", "Run day3");

    const day4 = dayExecuteable(b, 4, .{ .t = target, .o = optimize });
    b.installArtifact(day3);
    _ = runDay(b, day4, "day4", "Run day4");
}
