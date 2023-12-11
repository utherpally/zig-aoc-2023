const CardsKind = enum(u8) {
    high_card,
    one_pair,
    two_pairs,
    three_of_a_kind,
    full_house,
    four_of_a_kind,
    five_of_a_kind,
};

const Card = enum(u8) {
    @"2",
    @"3",
    @"4",
    @"5",
    @"6",
    @"7",
    @"8",
    @"9",
    T,
    J,
    Q,
    K,
    A,
};

const Cards = packed struct(u64) {
    kind: CardsKind,
    // cards: [5]Card, // zig packed struct doesn't support arrays yet
    card1: Card,
    card2: Card,
    card3: Card,
    card4: Card,
    card5: Card,
    _padding: u16 = 0,

    fn getCards(self: @This()) [5]Card {
        return [5]Card{ self.card1, self.card2, self.card3, self.card4, self.card5 };
    }
};
const Hand = struct {
    cards: Cards,
    bid: u32,
};

fn parseHands(
    allocator: mem.Allocator,
    comptime use_joker_rules: bool,
) ![]Hand {
    var hands = try std.ArrayList(Hand).initCapacity(allocator, 1000);
    defer hands.deinit();

    var iter = mem.tokenizeAny(u8, input, " \n");

    while (iter.next()) |s| {
        var cards: [5]Card = undefined;
        for (s, 0..) |c, i| {
            cards[i] = switch (c) {
                '2' => .@"2",
                '3' => .@"3",
                '4' => .@"4",
                '5' => .@"5",
                '6' => .@"6",
                '7' => .@"7",
                '8' => .@"8",
                '9' => .@"9",
                'T' => .T,
                'J' => .J,
                'Q' => .Q,
                'K' => .K,
                'A' => .A,
                else => unreachable,
            };
        }
        const kind: CardsKind = blk: {
            var v = [_]u8{0} ** 13;
            var joker_count: u8 = 0;
            for (cards) |card| {
                if (use_joker_rules and card == .J) {
                    joker_count += 1;
                } else {
                    v[@intFromEnum(card)] += 1;
                }
            }
            var max: u8 = 0;
            var count: u8 = 0;
            for (v) |i| {
                max = @max(i, max);
                if (i > 0) count += 1;
            }
            max += joker_count;

            break :blk switch (count) {
                0, 1 => .five_of_a_kind, // 0 means all jokers when using joker rules
                2 => if (max == @as(u8, 4)) .four_of_a_kind else .full_house,
                3 => if (max == @as(u8, 3)) .three_of_a_kind else .two_pairs,
                4 => .one_pair,
                5 => .high_card,
                else => unreachable,
            };
        };
        hands.appendAssumeCapacity(.{
            .cards = .{
                .kind = kind,
                .card1 = cards[0],
                .card2 = cards[1],
                .card3 = cards[2],
                .card4 = cards[3],
                .card5 = cards[4],
            },
            .bid = try std.fmt.parseUnsigned(u32, iter.next().?, 10),
        });
    }

    return hands.toOwnedSlice();
}

pub fn part1() !void {
    const allocator = std.heap.page_allocator;
    const hands = try parseHands(allocator, false);
    defer allocator.free(hands);

    const Sort = struct {
        fn lessThan(context: void, lhs: Hand, rhs: Hand) bool {
            _ = context;
            const a = mem.readInt(u64, mem.asBytes(&lhs.cards), .big);
            const b = mem.readInt(u64, mem.asBytes(&rhs.cards), .big);
            return a < b;
        }
    };
    mem.sortUnstable(Hand, hands, {}, Sort.lessThan);

    var sum: usize = 0;
    for (hands, 1..) |hand, rank| {
        sum += rank * hand.bid;
    }

    print("Part 1: {d}\n", .{sum});
}

pub fn part2() !void {
    const allocator = std.heap.page_allocator;
    const hands = try parseHands(allocator, true);
    defer allocator.free(hands);

    const Sort = struct {
        fn getPoint(card: Card) u8 {
            return if (card == .J) 0 else @intFromEnum(card) + 1;
        }

        inline fn getKindPoint(cards: Cards) u8 {
            return @intFromEnum(cards.kind);
        }

        fn lessThan(context: void, lhs: Hand, rhs: Hand) bool {
            _ = context;
            if (getKindPoint(lhs.cards) != getKindPoint(rhs.cards)) {
                return getKindPoint(lhs.cards) < getKindPoint(rhs.cards);
            }

            for (lhs.cards.getCards(), rhs.cards.getCards()) |a, b| {
                if (getPoint(a) != getPoint(b)) return getPoint(a) < getPoint(b);
            }
            return false;
        }
    };
    mem.sortUnstable(Hand, hands, {}, Sort.lessThan);

    var sum: usize = 0;
    for (hands, 1..) |hand, rank| {
        sum += rank * hand.bid;
    }

    print("Part 2: {d}\n", .{sum});
}

const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const input = if (@import("root").debug) @embedFile("example.txt") else @embedFile("input.txt");
