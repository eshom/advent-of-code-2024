const std = @import("std");

const example1 =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
    \\
;

const input = @embedFile("input/day1.txt");

const Lists = struct {
    left: []u64,
    right: []u64,
};

fn scanLists(ally: std.mem.Allocator, rd: []const u8) !*Lists {
    const nlines: usize = std.mem.count(u8, rd, "\n");

    const out = try ally.create(Lists);
    out.left = try ally.alloc(u64, nlines);
    out.right = try ally.alloc(u64, nlines);

    var lines = std.mem.tokenizeScalar(u8, rd, '\n');

    for (out.left, out.right) |*l, *r| {
        var lrit = std.mem.tokenizeScalar(u8, lines.next().?, ' ');

        l.* = try std.fmt.parseInt(u64, lrit.next().?, 10);
        r.* = try std.fmt.parseInt(u64, lrit.next().?, 10);
    }

    return out;
}

fn distSum(lists: *const Lists) u64 {
    var out: u64 = 0;
    for (lists.left, lists.right) |l, r| {
        out += std.math.sub(u64, l, r) catch r - l;
    }
    return out;
}

fn similarityScore(lookup: u64, sorted: []const u64) u64 {
    const idx_maybe = std.sort.binarySearch(
        u64,
        sorted,
        lookup,
        struct {
            fn orderU64(lhs: u64, rhs: u64) std.math.Order {
                return std.math.order(lhs, rhs);
            }
        }.orderU64,
    );

    if (idx_maybe) |idx_found| {
        var idx = idx_found;
        var min_idx = idx_found;
        while (idx > 0) {
            if (sorted[idx - 1] == sorted[idx_found]) {
                min_idx -= 1;
                idx -= 1;
            } else {
                break;
            }
        }

        idx = idx_found;
        var max_idx = idx_found;
        while (idx < sorted.len - 1) {
            if (sorted[idx + 1] == sorted[idx_found]) {
                max_idx += 1;
                idx += 1;
            } else {
                break;
            }
        }

        return (max_idx - min_idx + 1) * lookup;
    } else {
        return 0;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    const lists = try scanLists(ally, input);

    std.mem.sort(u64, lists.left, {}, std.sort.asc(u64));
    std.mem.sort(u64, lists.right, {}, std.sort.asc(u64));

    const part1 = distSum(lists);

    std.debug.print("part 1: {d}\n", .{part1});

    var part2: u64 = 0;
    for (lists.left) |num| {
        const score = similarityScore(num, lists.right);
        part2 += score;
    }

    std.debug.print("part 2: {d}\n", .{part2});
}
