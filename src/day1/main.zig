pub fn part1() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        for (line) |c| {
            if (isDigit(c)) {
                sum += (c - '0') * 10;
                break;
            }
        }

        var i = line.len - 1;
        while (i >= 0) : (i -= 1) {
            if (isDigit(line[i])) {
                sum += (line[i] - '0');
                break;
            }
        }
    }

    print("Sum: {}\n", .{sum});
}

pub fn part2() !void {
    var lines = mem.splitScalar(u8, input, '\n');

    var sum: usize = 0;
    while (lines.next()) |line| {
        var lastDigit: ?u8 = null;
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            const c = line[i];

            const digit = d: {
                if (mem.startsWith(u8, line[i..], "one")) break :d 1;
                if (mem.startsWith(u8, line[i..], "two")) break :d 2;
                if (mem.startsWith(u8, line[i..], "three")) break :d 3;
                if (mem.startsWith(u8, line[i..], "four")) break :d 4;
                if (mem.startsWith(u8, line[i..], "five")) break :d 5;
                if (mem.startsWith(u8, line[i..], "six")) break :d 6;
                if (mem.startsWith(u8, line[i..], "seven")) break :d 7;
                if (mem.startsWith(u8, line[i..], "eight")) break :d 8;
                if (mem.startsWith(u8, line[i..], "nine")) break :d 9;
                if (isDigit(c)) break :d c - '0';
                break :d null;
            };

            if (digit) |d| {
                if (lastDigit == null) sum += d * 10;
                lastDigit = d;
            }
        }
        if (lastDigit) |d| {
            sum += d;
        }
    }

    print("Sum: {}\n", .{sum});
}

const std = @import("std");
const isDigit = std.ascii.isDigit;
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
