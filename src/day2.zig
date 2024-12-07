const std = @import("std");

const example1 =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
    \\
;

const morecases =
    \\2 1 2 3 4
    \\5 1 2 3 4
    \\1 3 2 4 5
    \\
;

const input = @embedFile("input/day2.txt");

/// Safe:
/// The levels are either all increasing or all decreasing.
/// Any two adjacent levels differ by at least one and at most three.
fn safeNums(nums: []const u8) bool {
    var idx: usize = 1;
    var increasing = true;
    var decreasing = true;
    var valid_delta = true;
    while (idx < nums.len) : (idx += 1) {
        const delta = std.math.sub(u8, nums[idx], nums[idx - 1]) catch {
            increasing = false;
            const delta_r = nums[idx - 1] - nums[idx];
            valid_delta = if (delta_r >= 1 and delta_r <= 3) true else false;
            // short circuit based on safe rules
            if (!((increasing or decreasing) and valid_delta)) {
                return false;
            }
            continue;
        };
        decreasing = false;
        valid_delta = if (delta >= 1 and delta <= 3) true else false;
        // short circuit based on safe rules
        if (!((increasing or decreasing) and valid_delta)) {
            return false;
        }
    }

    return true;
}

/// if removing a single level from an unsafe report would make it safe, the report instead counts as safe.
fn safeNums2(ally: std.mem.Allocator, nums: []const u8, retry: bool) !bool {
    var idx: usize = 1;
    var increasing = true;
    var decreasing = true;
    var valid_delta = true;
    while (idx < nums.len) : (idx += 1) {
        const delta = std.math.sub(u8, nums[idx], nums[idx - 1]) catch {
            increasing = false;
            const delta_r = nums[idx - 1] - nums[idx];
            valid_delta = if (delta_r >= 1 and delta_r <= 3) true else false;
            // short circuit based on safe rules
            if (!((increasing or decreasing) and valid_delta)) {
                if (retry) {
                    for (0..nums.len) |omitid| {
                        var new_nums = std.ArrayList(u8).fromOwnedSlice(ally, try ally.dupe(u8, nums));
                        defer new_nums.deinit();
                        _ = new_nums.orderedRemove(omitid);
                        const res = try safeNums2(ally, new_nums.items, false);
                        std.debug.print("retry nums (desc): {d} - {}\n", .{ new_nums.items, res });
                        if (res) {
                            return res;
                        }
                    }
                }
                return false;
            }
            continue;
        };
        decreasing = false;
        valid_delta = if (delta >= 1 and delta <= 3) true else false;
        // short circuit based on safe rules
        if (!((increasing or decreasing) and valid_delta)) {
            if (retry) {
                for (0..nums.len) |omitid| {
                    var new_nums = std.ArrayList(u8).fromOwnedSlice(ally, try ally.dupe(u8, nums));
                    defer new_nums.deinit();
                    _ = new_nums.orderedRemove(omitid);
                    const res = try safeNums2(ally, new_nums.items, false);
                    std.debug.print("retry nums (asc): {d} - {}\n", .{ new_nums.items, res });
                    if (res) {
                        return res;
                    }
                }
            }
            return false;
        }
    }

    return true;
}

fn toIntSlc(ally: std.mem.Allocator, str_nums: []const u8) ![]u8 {
    const out = try ally.alloc(u8, std.mem.count(u8, str_nums, " ") + 1);
    var it = std.mem.tokenizeScalar(u8, str_nums, ' ');
    var idx: usize = 0;
    while (it.next()) |strn| : (idx += 1) {
        out[idx] = try std.fmt.parseInt(u8, strn, 10);
    }
    return out;
}

pub fn main() !void {
    var buf: [255]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const ally = fba.allocator();

    var lineit = std.mem.tokenizeScalar(u8, input, '\n');

    var safe_count: usize = 0;
    while (lineit.next()) |line| {
        const nums = try toIntSlc(ally, line);
        defer ally.free(nums);
        safe_count += if (safeNums(nums)) 1 else 0;
    }

    lineit.reset();
    var safe_count2: usize = 0;
    while (lineit.next()) |line| {
        const nums = try toIntSlc(ally, line);
        defer ally.free(nums);
        safe_count2 += if (try safeNums2(ally, nums, true)) 1 else 0;
    }

    std.debug.print("part 1: {d}\n", .{safe_count});
    std.debug.print("part 2: {d}\n", .{safe_count2});
}
