const Node = struct {
    left: []const u8,
    right: []const u8,
};

pub fn part1() !void {
    const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();
    var lines = mem.tokenizeAny(u8, input, "\n =(),");

    const loop_steps = lines.next().?;

    var map = std.StringHashMap(Node).init(allocator);

    while (lines.next()) |label| {
        const left = lines.next().?;
        const right = lines.next().?;
        try map.put(label, .{ .left = left, .right = right });
    }

    var current: []const u8 = "AAA";
    var steps: usize = 0;
    while (!mem.eql(u8, current, "ZZZ")) : (steps += 1) {
        const step = loop_steps[steps % loop_steps.len];
        const node = map.get(current) orelse @panic("Node not found");
        current = if (step == 'L') node.left else node.right;
    }

    print("Part 1: {d}\n", .{steps});
}

fn gcd(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    if (b == 0) {
        return a;
    }
    return gcd(b, @rem(a, b));
}

fn lcm(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a * b / gcd(a, b);
}

test {
    try expect(lcm(4, 5) == 20);
}

pub fn part2() !void {
    const input = if (@import("root").debug) @embedFile("example_part2.txt") else @embedFile("input.txt");
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();
    var lines = mem.tokenizeAny(u8, input, "\n =(),");

    const loop_steps = lines.next().?;

    var map = std.StringHashMap(Node).init(allocator);
    defer map.deinit();

    var list = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |label| {
        const left = lines.next().?;
        const right = lines.next().?;
        try map.put(label, .{ .left = left, .right = right });
        if (label[2] == 'A') {
            try list.append(label);
        }
    }

    const currents = try list.toOwnedSlice();

    var cycles = try allocator.alloc(usize, currents.len);
    defer allocator.free(cycles);

    for (currents, 0..) |*current, i| {
        var steps: usize = 0;
        while (true) {
            const step = loop_steps[steps % loop_steps.len];
            const node = map.get(current.*) orelse @panic("Node not found");
            current.* = if (step == 'L') node.left else node.right;
            steps += 1;
            if (current.*[2] == 'Z') {
                cycles[i] = steps;
                break;
            }
        }
    }

    var steps: usize = cycles[0];
    for (cycles[1..]) |cycle| {
        steps = lcm(steps, cycle);
    }

    print("Part 2: {d}\n", .{steps});
}

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const expect = std.testing.expect;
