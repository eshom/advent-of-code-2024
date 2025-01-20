const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const debug = std.debug;

const wordsearch = @embedFile("input/day4.txt");

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

const Direction = enum(usize) {
    left = 0,
    topleft,
    top,
    topright,
    right,
    bottomright,
    bottom,
    bottomleft,
    center,
};

const Circle = struct {
    d: [8]Direction = .{
        .left,
        .topleft,
        .top,
        .topright,
        .right,
        .bottomright,
        .bottom,
        .bottomleft,
    },
    v: [8]u8 = .{'.'} ** 8,
};

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

    pub fn search(self: *const WordSearch, where: Pos, part1: bool) u64 {
        if (part1) {
            return searchInternal(self, where, 0, .center);
        } else {
            return @intFromBool(searchInternal2(self, where));
        }
    }

    pub fn searchAll(self: *const WordSearch, part1: bool) u64 {
        var out: u64 = 0;
        for (0..self.rows) |r| {
            for (0..self.cols) |c| {
                out += search(self, Pos.init(r, c), part1);
            }
        }
        return out;
    }

    fn searchInternal(self: *const WordSearch, where: Pos, depth: u8, dir: Direction) u64 {
        var xmas_count: u64 = 0;
        switch (depth) {
            0 => {
                if (self.getRel(where, .center) == 'X') {
                    const circ = self.circle(where);
                    for (circ.v, circ.d) |v, d| {
                        if (v == 'M') {
                            xmas_count += self.searchInternal(relPos(where, d), depth + 1, d);
                        }
                    }
                }
            },
            1 => {
                if (self.getRel(where, dir) == 'A') {
                    xmas_count += self.searchInternal(relPos(where, dir), depth + 1, dir);
                }
            },
            2 => {
                if (self.getRel(where, dir) == 'S') {
                    return 1;
                }
            },
            else => return 0,
        }

        return xmas_count;
    }

    fn searchInternal2(self: *const WordSearch, where: Pos) bool {
        var m_count: u8 = 0;
        var s_count: u8 = 0;

        const center = self.getRel(where, .center);

        if (center != 'A') return false;

        const corners: [4]u8 = .{
            self.getRel(where, .topleft),
            self.getRel(where, .topright),
            self.getRel(where, .bottomleft),
            self.getRel(where, .bottomright),
        };

        for (corners) |c| {
            s_count += if (c == 'S') 1 else 0;
            m_count += if (c == 'M') 1 else 0;
        }

        return if (m_count == 2 and s_count == 2) true else false;
    }

    fn circle(self: *const WordSearch, center: Pos) Circle {
        var out = Circle{};
        out.v[@intFromEnum(Direction.left)] = self.getRel(center, .left);
        out.v[@intFromEnum(Direction.topleft)] = self.getRel(center, .topleft);
        out.v[@intFromEnum(Direction.top)] = self.getRel(center, .top);
        out.v[@intFromEnum(Direction.topright)] = self.getRel(center, .topright);
        out.v[@intFromEnum(Direction.right)] = self.getRel(center, .right);
        out.v[@intFromEnum(Direction.bottomright)] = self.getRel(center, .bottomright);
        out.v[@intFromEnum(Direction.bottom)] = self.getRel(center, .bottom);
        out.v[@intFromEnum(Direction.bottomleft)] = self.getRel(center, .bottomleft);
        return out;
    }

    fn top(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0) return '.';
        if (pos.row > self.rows - 1) return '.';
        if (pos.col > self.cols - 1) return '.';
        return self.contents[relPos(pos, .top).arr(self.cols)];
    }

    fn bottom(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row >= self.rows - 1) return '.';
        if (pos.col > self.cols - 1) return '.';
        return self.contents[relPos(pos, .bottom).arr(self.cols)];
    }

    fn left(self: *const WordSearch, pos: Pos) u8 {
        if (pos.col == 0) return '.';
        if (pos.col > self.cols - 1) return '.';
        if (pos.row > self.rows - 1) return '.';
        return self.contents[relPos(pos, .left).arr(self.cols)];
    }

    fn bottomleft(self: *const WordSearch, pos: Pos) u8 {
        if (pos.col == 0) return '.';
        if (pos.row >= self.rows - 1) return '.';
        if (pos.col > self.cols - 1) return '.';
        return self.contents[relPos(pos, .bottomleft).arr(self.cols)];
    }

    fn topleft(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0 or pos.col == 0) return '.';
        if (pos.row > self.rows - 1) return '.';
        if (pos.col > self.cols - 1) return '.';
        return self.contents[relPos(pos, .topleft).arr(self.cols)];
    }

    fn right(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row > self.rows - 1) return '.';
        if (pos.col >= self.cols - 1) return '.';
        return self.contents[relPos(pos, .right).arr(self.cols)];
    }

    fn bottomright(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row >= self.rows - 1) return '.';
        if (pos.col >= self.cols - 1) return '.';
        return self.contents[relPos(pos, .bottomright).arr(self.cols)];
    }

    fn topright(self: *const WordSearch, pos: Pos) u8 {
        if (pos.row == 0) return '.';
        if (pos.row > self.rows - 1) return '.';
        if (pos.col >= self.cols - 1) return '.';
        return self.contents[relPos(pos, .topright).arr(self.cols)];
    }

    fn getRel(self: *const WordSearch, pos: Pos, direction: Direction) u8 {
        return switch (direction) {
            .left => self.left(pos),
            .topleft => self.topleft(pos),
            .top => self.top(pos),
            .topright => self.topright(pos),
            .right => self.right(pos),
            .bottomright => self.bottomright(pos),
            .bottom => self.bottom(pos),
            .bottomleft => self.bottomleft(pos),
            .center => self.contents[pos.arr(self.cols)],
        };
    }
};

fn relPos(pos: Pos, direction: Direction) Pos {
    return switch (direction) {
        .left => Pos.init(pos.row, pos.col - 1),
        .topleft => Pos.init(pos.row - 1, pos.col - 1),
        .top => Pos.init(pos.row - 1, pos.col),
        .topright => Pos.init(pos.row - 1, pos.col + 1),
        .right => Pos.init(pos.row, pos.col + 1),
        .bottomright => Pos.init(pos.row + 1, pos.col + 1),
        .bottom => Pos.init(pos.row + 1, pos.col),
        .bottomleft => Pos.init(pos.row + 1, pos.col - 1),
        .center => pos,
    };
}

pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    // const ws = try WordSearch.init(ally, example);
    const ws = try WordSearch.init(ally, wordsearch);
    const part1 = ws.searchAll(true);
    const part2 = ws.searchAll(false);
    debug.print("part 1: {d}\n", .{part1});
    debug.print("part 2: {d}\n", .{part2});
}
