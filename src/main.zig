const std = @import("std");
const aoc_options = @import("aoc_options");
const aoc = @import("aoc");

pub const debug = aoc_options.debug;

pub fn main() !void {
    switch (aoc_options.part) {
        1 => try aoc.part1(),
        2 => try aoc.part2(),
        else => @panic(std.fmt.comptimePrint("Invalid part: {}", .{aoc_options.part})),
    }
}
test {
    _ = aoc;
}
