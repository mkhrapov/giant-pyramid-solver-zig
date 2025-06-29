const std = @import("std");
const math = std.math;
const print = std.debug.print;

const POS = u64;

var final: POS = 0;
var choices: [9]i32 = [_]i32{0} ** 9;
const lengths = [_]i32{ 5, 384, 336, 96, 168, 96, 96, 96, 96 };
var all_possible_positions: [9][384]POS = undefined;
var ptr: [9]i32 = [_]i32{0} ** 9;

const known_distances = [_][6]f64{
    [_]f64{ 1.0, 1.0, 1.0, 1.732, 2.0, 2.64575 },
    [_]f64{ 1.0, 1.0, 1.0, 1.0, 1.732, 2.0 },
    [_]f64{ 1.0, 1.0, 1.0, 1.732, 1.732, 2.64575 },
    [_]f64{ 1.0, 1.0, 1.0, 1.732, 1.732, 2.0 },
    [_]f64{ 1.0, 1.0, 1.0, 1.41421, 2.0, 2.23606 },
};

const coords = [_][3]f64{
    [_]f64{ 0.0, 0.0, 0.0 },
    [_]f64{ 1.0, 0.0, 0.0 },
    [_]f64{ 2.0, 0.0, 0.0 },
    [_]f64{ 3.0, 0.0, 0.0 },
    [_]f64{ 4.0, 0.0, 0.0 },
    [_]f64{ 0.5, 0.866, 0.0 },
    [_]f64{ 1.5, 0.866, 0.0 },
    [_]f64{ 2.5, 0.866, 0.0 },
    [_]f64{ 3.5, 0.866, 0.0 },
    [_]f64{ 1.0, 1.732, 0.0 },
    [_]f64{ 2.0, 1.732, 0.0 },
    [_]f64{ 3.0, 1.732, 0.0 },
    [_]f64{ 1.5, 2.598, 0.0 },
    [_]f64{ 2.5, 2.598, 0.0 },
    [_]f64{ 2.0, 3.464, 0.0 },
    [_]f64{ 0.5, 0.28867, 0.8165 },
    [_]f64{ 1.5, 0.28867, 0.8165 },
    [_]f64{ 2.5, 0.28867, 0.8165 },
    [_]f64{ 3.5, 0.28867, 0.8165 },
    [_]f64{ 1.0, 1.15467, 0.8165 },
    [_]f64{ 2.0, 1.15467, 0.8165 },
    [_]f64{ 3.0, 1.15467, 0.8165 },
    [_]f64{ 1.5, 2.02067, 0.8165 },
    [_]f64{ 2.5, 2.02067, 0.8165 },
    [_]f64{ 2.0, 2.88667, 0.8165 },
    [_]f64{ 1.0, 0.57734, 1.633 },
    [_]f64{ 2.0, 0.57734, 1.633 },
    [_]f64{ 3.0, 0.57734, 1.633 },
    [_]f64{ 1.5, 1.44334, 1.633 },
    [_]f64{ 2.5, 1.44334, 1.633 },
    [_]f64{ 2.0, 2.30934, 1.633 },
    [_]f64{ 1.5, 0.86601, 2.4495 },
    [_]f64{ 2.5, 0.86601, 2.4495 },
    [_]f64{ 2.0, 1.73201, 2.4495 },
    [_]f64{ 2.0, 1.15468, 3.266 },
};

const planes = [_][15]i32{
    [_]i32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 },
    [_]i32{ 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 24, 24, 24, 24, 24 },
    [_]i32{ 25, 26, 27, 28, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 },
    [_]i32{ 0, 5, 9, 12, 14, 15, 19, 22, 24, 25, 28, 30, 31, 33, 34 },
    [_]i32{ 1, 6, 10, 13, 16, 20, 23, 26, 29, 32, 32, 32, 32, 32, 32 },
    [_]i32{ 2, 7, 11, 17, 21, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27 },
    [_]i32{ 0, 1, 2, 3, 4, 15, 16, 17, 18, 25, 26, 27, 31, 32, 34 },
    [_]i32{ 5, 6, 7, 8, 19, 20, 21, 28, 29, 33, 33, 33, 33, 33, 33 },
    [_]i32{ 9, 10, 11, 22, 23, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 },
    [_]i32{ 4, 8, 11, 13, 14, 18, 21, 23, 24, 27, 29, 30, 32, 33, 34 },
    [_]i32{ 3, 7, 10, 12, 17, 20, 22, 26, 28, 31, 31, 31, 31, 31, 31 },
    [_]i32{ 2, 6, 9, 16, 19, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25 },
    [_]i32{ 5, 6, 7, 8, 15, 16, 17, 18, 18, 18, 18, 18, 18, 18, 18 },
    [_]i32{ 9, 10, 11, 19, 20, 21, 25, 26, 27, 27, 27, 27, 27, 27, 27 },
    [_]i32{ 12, 13, 22, 23, 28, 29, 31, 32, 32, 32, 32, 32, 32, 32, 32 },
    [_]i32{ 1, 6, 10, 13, 15, 19, 22, 24, 24, 24, 24, 24, 24, 24, 24 },
    [_]i32{ 2, 7, 11, 16, 20, 23, 25, 28, 30, 30, 30, 30, 30, 30, 30 },
    [_]i32{ 3, 8, 17, 21, 26, 29, 31, 33, 33, 33, 33, 33, 33, 33, 33 },
    [_]i32{ 3, 7, 10, 12, 18, 21, 23, 24, 24, 24, 24, 24, 24, 24, 24 },
    [_]i32{ 2, 6, 9, 17, 20, 22, 27, 29, 30, 30, 30, 30, 30, 30, 30 },
    [_]i32{ 1, 5, 16, 19, 26, 28, 32, 33, 33, 33, 33, 33, 33, 33, 33 },
};

fn set3(i: i32, j: i32, k: i32) POS {
    var p: POS = 0;
    const one: POS = 1;
    p |= one << @intCast(i);
    p |= one << @intCast(j);
    p |= one << @intCast(k);
    return p;
}

fn set4(i: i32, j: i32, k: i32, l: i32) POS {
    var p: POS = 0;
    const one: POS = 1;
    p |= one << @intCast(i);
    p |= one << @intCast(j);
    p |= one << @intCast(k);
    p |= one << @intCast(l);
    return p;
}

fn inPlane(plane_idx: i32, i: i32, j: i32, k: i32, l: i32) bool {
    var found_i = false;
    var found_j = false;
    var found_k = false;
    var found_l = false;

    for (0..15) |n| {
        if (planes[@intCast(plane_idx)][n] == i) {
            found_i = true;
        }
        if (planes[@intCast(plane_idx)][n] == j) {
            found_j = true;
        }
        if (planes[@intCast(plane_idx)][n] == k) {
            found_k = true;
        }
        if (planes[@intCast(plane_idx)][n] == l) {
            found_l = true;
        }
    }
    return found_i and found_j and found_k and found_l;
}

fn isPlanar(i: i32, j: i32, k: i32, l: i32) bool {
    for (0..21) |plane_idx| {
        if (inPlane(@intCast(plane_idx), i, j, k, l)) {
            return true;
        }
    }
    return false;
}

fn distance(i: i32, j: i32) f64 {
    const x1 = coords[@intCast(i)][0];
    const y1 = coords[@intCast(i)][1];
    const z1 = coords[@intCast(i)][2];
    const x2 = coords[@intCast(j)][0];
    const y2 = coords[@intCast(j)][1];
    const z2 = coords[@intCast(j)][2];

    const dx = x1 - x2;
    const dy = y1 - y2;
    const dz = z1 - z2;

    const sq = dx * dx + dy * dy + dz * dz;

    return @sqrt(sq);
}

fn bubbleSortSix(d: []f64) void {
    for (1..6) |i| {
        var j = i;
        while (j > 0) : (j -= 1) {
            if (d[j] < d[j - 1]) {
                const tmp = d[j - 1];
                d[j - 1] = d[j];
                d[j] = tmp;
            } else {
                break;
            }
        }
    }
}

fn aboutEqual(a: f64, b: f64) bool {
    const diff = @abs(a - b);
    return diff < 0.01;
}

fn isMatch(a: []const f64, b: []const f64) bool {
    for (0..6) |i| {
        if (!aboutEqual(a[i], b[i])) {
            return false;
        }
    }
    return true;
}

fn match(i: i32, j: i32, k: i32, l: i32) void {
    var distances = [_]f64{
        distance(i, j),
        distance(i, k),
        distance(i, l),
        distance(j, k),
        distance(j, l),
        distance(k, l),
    };

    bubbleSortSix(&distances);
    if (distances[5] > 2.66) {
        return;
    }

    for (0..5) |idx| {
        if (isMatch(&distances, &known_distances[idx])) {
            if (idx == 4) {
                all_possible_positions[idx + 1][@intCast(ptr[idx + 1])] = set4(i, j, k, l);
                ptr[idx + 1] += 1;
                all_possible_positions[idx + 2][@intCast(ptr[idx + 2])] = set4(i, j, k, l);
                ptr[idx + 2] += 1;
                all_possible_positions[idx + 3][@intCast(ptr[idx + 3])] = set4(i, j, k, l);
                ptr[idx + 3] += 1;
                all_possible_positions[idx + 4][@intCast(ptr[idx + 4])] = set4(i, j, k, l);
                ptr[idx + 4] += 1;
            } else {
                all_possible_positions[idx + 1][@intCast(ptr[idx + 1])] = set4(i, j, k, l);
                ptr[idx + 1] += 1;
            }
            return;
        }
    }
}

fn precompute() void {
    for (0..32) |i| {
        for (i + 1..33) |j| {
            for (j + 1..34) |k| {
                for (k + 1..35) |l| {
                    if (isPlanar(@intCast(i), @intCast(j), @intCast(k), @intCast(l))) {
                        match(@intCast(i), @intCast(j), @intCast(k), @intCast(l));
                    }
                }
            }
        }
    }
}

fn initialize() void {
    const one: POS = 1;
    for (0..35) |i| {
        final = final | (one << @intCast(i));
    }

    for (0..9) |i| {
        for (0..384) |j| {
            all_possible_positions[i][j] = 0;
        }
    }

    all_possible_positions[0][0] = set3(0, 1, 2);
    all_possible_positions[0][1] = set3(1, 2, 3);
    all_possible_positions[0][2] = set3(5, 6, 7);
    all_possible_positions[0][3] = set3(9, 10, 11);
    all_possible_positions[0][4] = set3(19, 20, 21);
}

fn search(level: i32, prev: POS) bool {
    if (level == 9) {
        if (prev == final) {
            return true;
        }
        return false;
    }

    for (0..@intCast(lengths[@intCast(level)])) |index| {
        const pos = all_possible_positions[@intCast(level)][index];
        if ((prev & pos) == 0) {
            if (search(level + 1, prev | pos)) {
                choices[@intCast(level)] = @intCast(index);
                return true;
            }
        }
    }

    return false;
}

fn display() void {
    var occupied = [_]i32{0} ** 35;
    const one: POS = 1;
    const zero: POS = 0;

    print("Choices:\n", .{});
    for (0..9) |i| {
        print("{} ", .{choices[i]});
    }
    print("\n", .{});

    for (0..9) |i| {
        const p = all_possible_positions[i][@intCast(choices[i])];
        for (0..35) |j| {
            const mask = one << @intCast(j);
            if ((p & mask) != zero) {
                occupied[j] = @intCast(i);
            }
        }
    }

    for (0..35) |i| {
        print("{} ", .{occupied[i] + 1});
    }
    print("\n", .{});
}

pub fn main() !void {
    initialize();
    
    const precompute_start = std.time.nanoTimestamp();
    precompute();
    const precompute_end = std.time.nanoTimestamp();
    
    const precompute_elapsed_ns = precompute_end - precompute_start;
    const precompute_elapsed_sec = @as(f64, @floatFromInt(precompute_elapsed_ns)) / 1_000_000_000.0;
    print("Precompute: {d:.6} sec\n", .{precompute_elapsed_sec});
    
    const search_start = std.time.nanoTimestamp();
    _ = search(0, 0);
    const search_end = std.time.nanoTimestamp();

    const search_elapsed_ns = search_end - search_start;
    const search_elapsed_sec = @as(f64, @floatFromInt(search_elapsed_ns)) / 1_000_000_000.0;
    print("Search: {d:.3} sec\n", .{search_elapsed_sec});
    
    display();
}