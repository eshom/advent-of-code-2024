const std = @import("std");

const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const memory = @embedFile("input/day3.txt");

const LAST = 4;

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

    fn init(input: []const u8) Parser {
        return Parser{ .input = input, .window = std.mem.window(u8, input, 5, 1) };
    }

    fn nextMulCandidate(self: *Parser) ?void {
        while (self.window.next()) |toks| {
            if (std.mem.eql(u8, "mul(", toks[1..])) {
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
            if (std.ascii.isDigit(first[LAST])) {
                const a_start_tmp: *const [1]u8 = &first[LAST];
                a_start = a_start_tmp;

                const lit_start_tmp: *const [1]u8 = &first[0];
                lit_start = lit_start_tmp;
            }
        } else {
            return null;
        }

        while (self.window.next()) |toks| {
            if (std.ascii.isDigit(toks[LAST])) {
                continue;
            } else if (toks[LAST] == ',') {
                a_len = @intFromPtr(&toks[LAST]) - @intFromPtr(a_start);
                break;
            } else {
                return null;
            }
        }

        // b
        const first_maybe_b = self.window.next();
        if (first_maybe_b) |first| {
            if (std.ascii.isDigit(first[LAST])) {
                const b_start_tmp: *const [1]u8 = &first[LAST];
                b_start = b_start_tmp;
            }
        } else {
            return null;
        }

        while (self.window.next()) |toks| {
            if (std.ascii.isDigit(toks[LAST])) {
                continue;
            } else if (toks[LAST] == ')') {
                b_len = @intFromPtr(&toks[LAST]) - @intFromPtr(b_start);
                lit_len = @intFromPtr(&toks[LAST]) + 1 - @intFromPtr(lit_start);
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

    std.debug.print("part 1: {d}\n", .{sum});
}
