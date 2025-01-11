const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const debug = std.debug;

const example =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
    \\
;

const WordSearch = struct {
    contents: []u8,
    rows: usize,
    cols: usize,

    fn init(allocator: mem.Allocator, input: []const u8) !WordSearch {
        const buf = try allocator.alloc(u8, input.len);
        @memcpy(buf, input);
        // TODO: get max rows and cols
        return .{ .contents = buf };
    }

    // TODO: get neighbor funcs
    fn top(self: *WordSearch) u8 {
        _ = self; // autofix
    }
    fn bottom(self: *WordSearch) u8 {
        _ = self; // autofix
    }
};

pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var ws = try WordSearch.init(ally, example);
    debug.print("{s}\n", .{ws.contents});
}
