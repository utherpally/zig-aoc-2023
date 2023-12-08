pub fn part1() !void {
    const width = mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;
    var sum: u32 = 0;
    for (0..height) |i| {
        var start_idx: ?usize = null;
        for (0..width) |j| {
            const pos = i * width + j;
            const c = input[pos];
            const digit = isDigit(c);
            if (digit) {
                if (start_idx == null) start_idx = pos;
            } else if (start_idx) |start| {
                const end = pos;
                const num = try std.fmt.parseInt(u32, input[start..end], 10);
                if (hasNeighbor(start, end, width)) {
                    sum += num;
                }
                start_idx = null;
            }
        }
    }

    print("Sum: {d}\n", .{sum});
}

fn hasNeighbor(start: usize, end: usize, width: usize) bool {
    if (start > 0 and isSymbol(input[start - 1])) return true;
    if (isSymbol(input[end])) return true;
    if (start > width) {
        for (start - width - 1..end - width + 1) |k| {
            if (isSymbol(input[k])) return true;
        }
    }
    if (end + width < input.len) {
        for (start + width - 1..end + width + 1) |k| {
            if (isSymbol(input[k])) return true;
        }
    }
    return false;
}

fn isSymbol(c: u8) bool {
    return switch (c) {
        '0'...'9', '.', '\n' => false,
        else => true,
    };
}

const Map = std.AutoArrayHashMap(usize, struct {
    count: u32,
    product: u32,
});

pub fn part2() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const width = mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;

    var map = Map.init(arena);
    defer map.deinit();

    var sum: u32 = 0;
    for (0..height) |i| {
        var start_idx: ?usize = null;
        for (0..width) |j| {
            const pos = i * width + j;
            const c = input[pos];
            const digit = isDigit(c);
            if (digit) {
                if (start_idx == null) start_idx = pos;
            } else if (start_idx) |start| {
                const end = pos;
                try updateNeighbors(&map, start, end, width);
                start_idx = null;
            }
        }
    }

    var iter = map.iterator();

    while (iter.next()) |entry| {
        if (entry.value_ptr.count == 2) {
            sum += entry.value_ptr.product;
        }
    }

    print("Sum: {d}\n", .{sum});
}

fn updateMap(map: *Map, key: usize, value: u32) !void {
    const gop = try map.getOrPut(key);
    if (gop.found_existing) {
        gop.value_ptr.count += 1;
        gop.value_ptr.product *= value;
    } else {
        gop.value_ptr.* = .{
            .count = 1,
            .product = value,
        };
    }
}

fn updateNeighbors(map: *Map, start: usize, end: usize, width: usize) !void {
    const num = try std.fmt.parseInt(u32, input[start..end], 10);
    if (start > 0 and isStarSymbol(input[start - 1])) {
        try updateMap(map, start - 1, num);
    }
    if (isStarSymbol(input[end])) {
        try updateMap(map, end, num);
    }
    if (start > width) {
        for (start - width - 1..end - width + 1) |k| {
            if (isStarSymbol(input[k])) {
                try updateMap(map, k, num);
            }
        }
    }
    if (end + width < input.len) {
        for (start + width - 1..end + width + 1) |k| {
            if (isStarSymbol(input[k])) {
                try updateMap(map, k, num);
            }
        }
    }
}

fn isStarSymbol(c: u8) bool {
    return c == '*';
}

const std = @import("std");
const isDigit = std.ascii.isDigit;
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
