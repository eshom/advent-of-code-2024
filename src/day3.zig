const std = @import("std");

// spaces gets appended to the input because otherwise the window iterator overflows :-)
const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))" ++ " " ** WINDOW_SIZE;
const example2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))" ++ " " ** WINDOW_SIZE;
const memory = @embedFile("input/day3.txt") ++ " " ** WINDOW_SIZE;

const LAST_MUL = 4;
const WINDOW_SIZE = 8;

const InstMul = struct {
    lit: []const u8,
    a: u32,
    b: u32,

    fn eval(self: *const InstMul) u64 {
        return self.a * self.b;
    }
};

const Parser = struct {
    input: []const u8,
    window: std.mem.WindowIterator(u8),
    enabled: bool = true,

    fn init(input: []const u8) Parser {
        return Parser{ .input = input, .window = std.mem.window(u8, input, WINDOW_SIZE, 1) };
    }

    fn updateEnabled(self: *Parser, toks: []const u8) void {
        if (std.mem.eql(u8, "do()", toks[1 .. LAST_MUL + 1])) {
            std.debug.print("enabled\n", .{});
            self.enabled = true;
        }

        if (std.mem.eql(u8, "don't()", toks[1 .. LAST_MUL + 4])) {
            std.debug.print("disabled\n", .{});
            self.enabled = false;
        }
    }

    fn nextMulCandidate(self: *Parser) ?void {
        while (self.window.next()) |toks| {
            self.updateEnabled(toks);
            if (std.mem.eql(u8, "mul(", toks[1 .. LAST_MUL + 1])) {
                return;
            }
        } else {
            return null;
        }
    }

    fn parseMul(self: *Parser) ?InstMul {
        var out: InstMul = undefined;

        var a_start: [*]const u8 = undefined;
        var b_start: [*]const u8 = undefined;
        var lit_start: [*]const u8 = undefined;
        var a_len: usize = undefined;
        var b_len: usize = undefined;
        var lit_len: usize = undefined;

        // a
        const first_maybe = self.window.next();
        if (first_maybe) |first| {
            self.updateEnabled(first);
            if (std.ascii.isDigit(first[LAST_MUL])) {
                const a_start_tmp: *const [1]u8 = &first[LAST_MUL];
                a_start = a_start_tmp;

                const lit_start_tmp: *const [1]u8 = &first[0];
                lit_start = lit_start_tmp;
            }
        } else {
            return null;
        }

        while (self.window.next()) |toks| {
            self.updateEnabled(toks);
            if (std.ascii.isDigit(toks[LAST_MUL])) {
                continue;
            } else if (toks[LAST_MUL] == ',') {
                a_len = @intFromPtr(&toks[LAST_MUL]) - @intFromPtr(a_start);
                break;
            } else {
                return null;
            }
        }

        // b
        const first_maybe_b = self.window.next();
        if (first_maybe_b) |first| {
            self.updateEnabled(first);
            if (std.ascii.isDigit(first[LAST_MUL])) {
                const b_start_tmp: *const [1]u8 = &first[LAST_MUL];
                b_start = b_start_tmp;
            }
        } else {
            return null;
        }

        while (self.window.next()) |toks| {
            self.updateEnabled(toks);
            if (std.ascii.isDigit(toks[LAST_MUL])) {
                continue;
            } else if (toks[LAST_MUL] == ')') {
                b_len = @intFromPtr(&toks[LAST_MUL]) - @intFromPtr(b_start);
                lit_len = @intFromPtr(&toks[LAST_MUL]) + 1 - @intFromPtr(lit_start);
                break;
            } else {
                return null;
            }
        }

        out.a = std.fmt.parseInt(u32, a_start[0..a_len], 10) catch unreachable;
        out.b = std.fmt.parseInt(u32, b_start[0..b_len], 10) catch unreachable;
        out.lit = lit_start[0..lit_len];

        return out;
    }
};

pub fn main() !void {
    var par = Parser.init(memory);

    var sum: u64 = 0;
    while (par.nextMulCandidate() != null) {
        const mul = par.parseMul() orelse continue;
        sum += mul.eval();
    }

    std.debug.print("part 1: {d}\n\n", .{sum});

    par.window.reset();
    par.enabled = true;
    var sum2: u64 = 0;
    while (par.nextMulCandidate() != null) {
        const mul = par.parseMul() orelse continue;
        std.debug.print("lit: {s}\n", .{mul.lit});
        if (par.enabled) {
            sum2 += mul.eval();
        }
    }

    std.debug.print("part 2: {d}\n", .{sum2});
}
