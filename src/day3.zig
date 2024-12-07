const std = @import("std");

const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const memory = @embedFile("input/day3.txt");

const LAST = 4;

const InstMul = struct {
    lit: []const u8,
    a: u32,
    b: u32,
};

const Parser = struct {
    input: []const u8,
    window: std.mem.WindowIterator(u8),

    fn init(input: []const u8) Parser {
        return Parser{ .input = input, .window = std.mem.window(u8, input, 5, 1) };
    }

    fn nextMul(self: *Parser) void {
        while (self.window.next()) |toks| {
            if (std.mem.eql(u8, "mul(", toks[1..])) {
                return;
            }
        }
    }

    /// returns null if not a valid instruction
    fn parseNul(self: *Parser) ?InstMul {
        const out: InstMul = undefined;
        while (self.window.next()) |toks| {
            if (std.ascii.isDigit(toks[LAST])) {
                const a_start_ptr: [*]u8 = &toks[LAST];
                var len_a: usize = 1;
                while (self.window.next()) |toks2| : (len_a += 1) {
                    if (std.ascii.isDigit(toks2[LAST])) {
                        continue;
                    }
                    if (toks2[LAST] == ',') {
                        break;
                    }
                }
                // Repeat for len_b, outer loop probably not necessary
                const a_start_str = a_start_ptr[0..len_a];
                out.a = std.fmt.parseInt(u32, a_start_str, 10) catch unreachable;
            } else {
                return null;
            }
        }
    }
};

pub fn main() !void {
    var par = Parser.init(example);
    par.nextMul();
    // std.debug.print("{s}\n", .{par.window.next().?});
}
