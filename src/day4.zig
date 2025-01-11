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

const Pos = struct {
    row: usize,
    col: usize,

    pub fn init(row: usize, col: usize) Pos {
        return .{ .row = row, .col = col };
    }

    pub fn arr(self: Pos, cols: usize) usize {
        return self.row * cols + self.col;
    }
};

const WordSearch = struct {
    contents: []u8,
    rows: usize,
    cols: usize,
    pub fn format(value: WordSearch, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("WordSearch[{d}][{d}]\n", .{ value.rows, value.cols });
        for (0..value.rows) |r| {
            for (0..value.cols) |c| {
                try writer.writeByte(value.contents[Pos.init(r, c).arr(value.cols)]);
            }
            try writer.writeByte('\n');
        }
    }

    pub fn init(allocator: mem.Allocator, input: []const u8) !WordSearch {
        const buf = try allocator.alloc(u8, input.len);
        var rows: usize = 0;
        var cols: usize = 0;

        var new_idx: usize = 0;
        for (0..input.len) |idx| {
            rows += if (input[idx] == '\n') 1 else 0;
            cols += if (rows == 0) 1 else 0;
            buf[new_idx] = if (input[idx] == '\n') continue else input[idx];
            new_idx += 1;
        }

        return .{ .contents = buf[0 .. rows * cols], .rows = rows, .cols = cols };
    }

    fn top(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0) return '.';
        if (pos.row > self.rows) return '.';
        if (pos.col >= self.cols) return '.';
        return self.contents[Pos.init(pos.row - 1, pos.col).arr(self.cols)];
    }

    fn bottom(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row >= self.rows) return '.';
        if (pos.col >= self.cols) return '.';
        return self.contents[Pos.init(pos.row + 1, pos.col).arr(self.cols)];
    }

    fn left(self: *const WordSearch, pos: Pos) u8 {
        if (pos.col == 0) return '.';
        if (pos.col > self.cols) return '.';
        if (pos.row >= self.rows) return '.';
        return self.contents[Pos.init(pos.row, pos.col - 1).arr(self.cols)];
    }

    fn bottomleft(self: *const WordSearch, pos: Pos) u8 {
        if (pos.col == 0) return '.';
        if (pos.row >= self.rows) return '.';
        if (pos.col > self.cols) return '.';
        return self.contents[Pos.init(pos.row + 1, pos.col - 1).arr(self.cols)];
    }

    fn topleft(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0 and pos.col == 0) return '.';
        if (pos.row > self.rows and pos.col > self.cols) return '.';
        return self.contents[Pos.init(pos.row - 1, pos.col - 1).arr(self.cols)];
    }

    fn right(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row >= self.rows) return '.';
        if (pos.col >= self.cols) return '.';
        return self.contents[Pos.init(pos.row, pos.col + 1).arr(self.cols)];
    }

    fn bottomright(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row >= self.rows) return '.';
        if (pos.col >= self.cols) return '.';
        return self.contents[Pos.init(pos.row + 1, pos.col + 1).arr(self.cols)];
    }

    fn topright(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0) return '.';
        if (pos.row > self.rows) return '.';
        if (pos.col >= self.cols) return '.';
        return self.contents[Pos.init(pos.row - 1, pos.col + 1).arr(self.cols)];
    }
};

pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    const ws = try WordSearch.init(ally, example);
    debug.print("{}\n", .{ws});
    debug.print("top[0][0] = '{c}' (expecting = '.')\n", .{ws.top(Pos.init(0, 0))});
    debug.print("top[1][3] = '{c}' (expecting = 'S')\n", .{ws.top(Pos.init(1, 3))});
    debug.print("top[9][1] = '{c}' (expecting = 'A')\n", .{ws.top(Pos.init(9, 1))});
    debug.print("top[10][1] = '{c}' (expecting = 'X')\n", .{ws.top(Pos.init(10, 1))});
    debug.print("top[11][1] = '{c}' (expecting = '.')\n", .{ws.top(Pos.init(11, 1))});
    debug.print("bottom[0][0] = '{c}' (expecting = '.')\n", .{ws.bottom(Pos.init(0, 0))});
    debug.print("bottom[2][9] = '{c}' (expecting = 'X')\n", .{ws.bottom(Pos.init(2, 9))});
    debug.print("left[9][10] = '{c}' (expecting = 'X')\n", .{ws.left(Pos.init(9, 10))});
    debug.print("right[9][10] = '{c}' (expecting = '.')\n", .{ws.left(Pos.init(9, 10))});
    debug.print("right[8][4] = '{c}' (expecting = 'X')\n", .{ws.right(Pos.init(8, 4))});
    debug.print("topleft[10][10] = '{c}' (expecting = 'X')\n", .{ws.topleft(Pos.init(10, 10))});
    debug.print("topright[10][0] = '{c}' (expecting = 'X')\n", .{ws.topright(Pos.init(10, 0))});
    debug.print("bottomleft[6][10] = '{c}' (expecting = 'A')\n", .{ws.bottomleft(Pos.init(6, 10))});
    debug.print("bottomright[0][0] = '{c}' (expecting = 'S')\n", .{ws.bottomright(Pos.init(0, 0))});
}
