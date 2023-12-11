pub fn part1() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    var time_iter = mem.tokenizeScalar(u8, lines.next().?["Time:".len..], ' ');
    var distance_iter = mem.tokenizeScalar(u8, lines.next().?["Distance:".len..], ' ');

    var result: u64 = 1;
    while (time_iter.next()) |s| {
        const time = std.fmt.parseUnsigned(u64, s, 10) catch unreachable;
        const distance = std.fmt.parseUnsigned(u64, distance_iter.next().?, 10) catch unreachable;
        result *= winCount(time, distance);
    }

    print("Part 1: {d}\n", .{result});
}

pub fn part2() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    const time = toNumber(lines.next().?["Time:".len..]);
    const distance = toNumber(lines.next().?["Distance:".len..]);

    print("Part 2: {d}\n", .{winCount(time, distance)});
}

fn winCount(time: u64, distance: u64) u64 {
    // x * (time - x) > distance
    // <=> x^2 - time * x + distance > 0
    // <=> (time - sqrt(time^2 - 4 * distance)) / 2 < x < (time + sqrt(time^2 - 4 * distance)) / 2
    const t: f64 = @floatFromInt(time);
    const d: f64 = @floatFromInt(distance);
    const delta = t * t - 4 * d;
    const x1 = (t - sqrt(delta)) / 2;
    const x2 = (t + sqrt(delta)) / 2;

    const min = if (@trunc(x1) == x1) x1 + 1 else @ceil(x1);
    const max = if (@trunc(x2) == x2) x2 - 1 else @floor(x2);
    return @intFromFloat(max - min + 1);
}

fn toNumber(str: []const u8) u64 {
    var result: u64 = 0;
    for (str) |c| {
        if (c != ' ') {
            result = result * 10 + c - '0';
        }
    }
    return result;
}

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const sqrt = std.math.sqrt;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
