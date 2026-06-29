const std = @import("std");

x: f64 = 0,
y: f64 = 0,
z: f64 = 0,

const Vec3 = @This();
pub const Point3 = Vec3;

// --- Namespace Functions (Operate on two distinct inputs) ---

pub fn add(u: Vec3, v: Vec3) Vec3 {
    return .{ .x = u.x + v.x, .y = u.y + v.y, .z = u.z + v.z };
}

pub fn sub(u: Vec3, v: Vec3) Vec3 {
    return .{ .x = u.x - v.x, .y = u.y - v.y, .z = u.z - v.z };
}

pub fn mul(u: Vec3, v: Vec3) Vec3 {
    return .{ .x = u.x * v.x, .y = u.y * v.y, .z = u.z * v.z };
}

pub fn dot(u: Vec3, v: Vec3) f64 {
    return u.x * v.x + u.y * v.y + u.z * v.z;
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return .{
        .x = u.y * v.z - u.z * v.y,
        .y = u.z * v.x - u.x * v.z,
        .z = u.x * v.y - u.y * v.x,
    };
}

// --- Method Functions (Operate on the instance itself) ---

pub fn scale(self: Vec3, t: f64) Vec3 {
    return .{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
}

pub fn div(self: Vec3, t: f64) Vec3 {
    return self.scale(1.0 / t);
}

pub fn addAssign(self: *Vec3, v: Vec3) void {
    self.x += v.x;
    self.y += v.y;
    self.z += v.z;
}

pub fn scaleAssign(self: *Vec3, t: f64) void {
    self.x *= t;
    self.y *= t;
    self.z *= t;
}

pub fn lengthSquared(self: Vec3) f64 {
    return self.x * self.x + self.y * self.y + self.z * self.z;
}

pub fn length(self: Vec3) f64 {
    return @sqrt(self.lengthSquared());
}

pub fn unitVector(self: Vec3) Vec3 {
    return self.div(self.length());
}

// --- format ---

pub fn format(
    self: Vec3,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;
    try writer.print("{d} {d} {d}", .{ self.x, self.y, self.z });
}
