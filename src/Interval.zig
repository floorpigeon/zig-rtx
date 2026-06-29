const std = @import("std");

min: f64,
max: f64,

const Interval = @This();

pub const empty: Interval = .{ .min = std.math.inf(f64), .max = -std.math.inf(f64) };

pub const universe: Interval = .{ .min = -std.math.inf(f64), .max = std.math.inf(f64) };

pub fn size(self: Interval) void {
    return self.max - self.min;
}

pub fn contains(self: Interval, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Interval, x: f64) bool {
    return self.min < x and x < self.max;
}
