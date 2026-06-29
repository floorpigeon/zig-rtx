const std = @import("std");

e: [3]f64,

const Vec3 = @This();

// point3 just an alias for Vec3

pub const Point3 = Vec3;

pub fn init(e0: f64, e1: f64, e2: f64) Vec3 {
    return .{ .e = .{ e0, e1, e2 } };
}

pub fn x(self: Vec3) f64 {
    return self.e[0];
}
pub fn y(self: Vec3) f64 {
    return self.e[1];
}
pub fn z(self: Vec3) f64 {
    return self.e[2];
}
