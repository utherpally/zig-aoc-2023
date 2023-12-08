pub fn part1() !void {
    var lines = mem.splitScalar(u8, input, '\n');

    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var items = mem.tokenizeScalar(u8, line[5..], ' ');
        _ = items.next(); // skip card No e.g. 1:
        var winners = BitSet.initEmpty();
        while (items.next()) |item| {
            if (item[0] == '|') break;
            winners.set(try std.fmt.parseInt(u16, item, 10));
        }

        var mycards = BitSet.initEmpty();
        while (items.next()) |item| {
            mycards.set(try std.fmt.parseInt(u16, item, 10));
        }
        const mached_numbers = winners.intersectWith(mycards).count();
        if (mached_numbers > 0) {
            sum += std.math.pow(usize, 2, mached_numbers - 1);
        }
    }

    print("Sum: {d}\n", .{sum});
}

pub fn part2() !void {
    var lines = mem.splitScalar(u8, input, '\n');
    const card_num = comptime blk: {
        const width = mem.indexOfScalar(u8, input, '\n').? + 1;
        break :blk input.len / width;
    };
    var copies: @Vector(card_num, usize) = @splat(1);

    var idx: u32 = 0;
    while (lines.next()) |line| : (idx += 1) {
        if (line.len == 0) continue;
        var items = mem.tokenizeScalar(u8, line[5..], ' ');
        _ = items.next(); // skip card No.
        var winners = BitSet.initEmpty();
        while (items.next()) |item| {
            if (item[0] == '|') break;
            winners.set(try std.fmt.parseInt(u16, item, 10));
        }

        var mycards = BitSet.initEmpty();
        while (items.next()) |item| {
            mycards.set(try std.fmt.parseInt(u16, item, 10));
        }
        const mached_numbers = winners.intersectWith(mycards).count();
        for (idx + 1..idx + 1 + mached_numbers) |i| {
            copies[i] += copies[idx];
        }
    }
    print("Sum: {d}\n", .{@reduce(.Add, copies)});
}

const BitSet = std.bit_set.IntegerBitSet(100);

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
