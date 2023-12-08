pub fn part1() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    var sum: usize = 0;
    outer: while (lines.next()) |line| {
        if (line.len == 0) continue;
        // Example line (without the quotes):
        // "Game 78: 2 red, 4 green, 1 blue; 4 green, 1 blue, 6 red; 7 green, 1 blue"
        var iter = mem.tokenizeAny(u8, line[5..], " :"); // +5 to skip "Game " part

        const id = try std.fmt.parseInt(usize, iter.next().?, 10); // skip the colon
        while (iter.next()) |s| {
            const qty = try std.fmt.parseInt(usize, s, 10);
            const maxQty: usize = switch (iter.next().?[0]) {
                'r' => 12,
                'g' => 13,
                'b' => 14,
                else => unreachable,
            };
            if (qty > maxQty) continue :outer;
        }
        sum += id;
    }

    print("Sum: {}\n", .{sum});
}

pub fn part2() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var iter = mem.splitScalar(u8, line[mem.indexOfScalar(u8, line, ':').? + 2 ..], ' ');
        var min: [3]u32 = .{ 0, 0, 0 };
        while (iter.next()) |s| {
            const qty = try std.fmt.parseInt(u32, s, 10);
            switch (iter.next().?[0]) {
                'r' => min[0] = @max(qty, min[0]),
                'g' => min[1] = @max(qty, min[1]),
                'b' => min[2] = @max(qty, min[2]),
                else => unreachable,
            }
        }
        sum += min[0] * min[1] * min[2];
    }

    print("Sum: {}\n", .{sum});
}

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
