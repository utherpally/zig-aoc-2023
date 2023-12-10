pub fn part1() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();

    var lines = mem.splitScalar(u8, input, '\n');

    const seed_line = lines.next().?;

    var seeds = mem.splitScalar(u8, seed_line[7..], ' ');

    var list = std.ArrayList(struct { number: usize, visited: bool }).init(allocator);
    defer list.deinit();

    while (seeds.next()) |seed| {
        try list.append(.{
            .number = try std.fmt.parseUnsigned(usize, seed, 10),
            .visited = false,
        });
    }

    while (lines.next()) |line| {
        if (line.len == 0) {
            for (list.items) |*item| item.visited = false;
            _ = lines.next(); // Skip next line as well
            continue;
        }
        var words = mem.splitScalar(u8, line, ' ');
        const dest_start = try std.fmt.parseUnsigned(usize, words.next().?, 10);
        const src_start = try std.fmt.parseUnsigned(usize, words.next().?, 10);
        const src_len = try std.fmt.parseUnsigned(usize, words.next().?, 10);

        for (list.items) |*item| {
            if (!item.visited and item.number >= src_start and item.number < src_start + src_len) {
                item.number = dest_start + (item.number - src_start);
                item.visited = true;
            }
        }
    }
    var lowest_location_number = list.items[0].number;
    for (list.items[1..]) |item| {
        if (item.number < lowest_location_number) {
            lowest_location_number = item.number;
        }
    }
    print("Lowest location number: {d}\n", .{lowest_location_number});
}

pub fn part2() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();

    var lines = mem.splitScalar(u8, input, '\n');

    const seed_line = lines.next().?;
    var seeds = mem.splitScalar(u8, seed_line[7..], ' ');

    const Range = struct {
        start: usize,
        len: usize,

        pub fn end(self: *const @This()) usize {
            return self.start + self.len - 1;
        }
    };

    var list = std.ArrayList(struct {
        range: Range,
        visited: bool = false,
    }).init(allocator);
    defer list.deinit();

    while (seeds.next()) |seed| {
        try list.append(.{
            .range = .{
                .start = try std.fmt.parseUnsigned(usize, seed, 10),
                .len = try std.fmt.parseUnsigned(usize, seeds.next().?, 10),
            },
        });
    }
    while (lines.next()) |line| {
        if (line.len == 0) {
            for (list.items) |*item| item.visited = false;
            _ = lines.next(); // Skip next line as well
            continue;
        }
        var words = mem.splitScalar(u8, line, ' ');
        const dest_start = try std.fmt.parseUnsigned(usize, words.next().?, 10);
        const src: Range = .{
            .start = try std.fmt.parseUnsigned(usize, words.next().?, 10),
            .len = try std.fmt.parseUnsigned(usize, words.next().?, 10),
        };
        const dest: Range = .{ .start = dest_start, .len = src.len };
        var i: usize = 0;
        while (i < list.items.len) : (i += 1) {
            const item = &list.items[i];
            if (!item.visited) {
                const r = item.range;
                const overlap_start = @max(r.start, src.start);
                const overlap_end = @min(r.end(), src.end());
                if (overlap_start <= overlap_end) {
                    if (overlap_start > r.start) {
                        try list.append(.{ .range = .{
                            .start = r.start,
                            .len = overlap_start - r.start,
                        } });
                    }
                    if (overlap_end < r.end()) {
                        try list.append(.{ .range = .{
                            .start = overlap_end + 1,
                            .len = r.end() - overlap_end,
                        } });
                    }
                    // list will be reallocated here,
                    // so we need to update our pointer to list.items directly
                    list.items[i].range.start = dest.start + (overlap_start - src.start);
                    list.items[i].range.len = overlap_end - overlap_start + 1;
                    list.items[i].visited = true;
                }
            }
        }
    }
    var lowest_location_number = list.items[0].range.start;
    for (list.items[1..]) |item| {
        if (item.range.start < lowest_location_number) {
            lowest_location_number = item.range.start;
        }
    }
    print("Lowest location number: {d}\n", .{lowest_location_number});
}

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
