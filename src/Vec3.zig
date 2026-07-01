const std = @import("std");
const rng = @import("random.zig");

x: f64 = 0,
y: f64 = 0,
z: f64 = 0,

const Vec3 = @This();
pub const Point3 = Vec3;

// --- Namespace Functions (Operate on two distinct inputs) ---
// (Can also be used as methods)

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
// (Intended to be used as methods)

pub fn nearZero(self: Vec3) bool {
    const s = 1e-8;
    return @abs(self.x) < s and @abs(self.y) < s and @abs(self.z) < s;
}

pub fn scale(self: Vec3, t: f64) Vec3 {
    return .{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
}

pub fn div(self: Vec3, t: f64) Vec3 {
    return self.scale(1.0 / t);
}

pub fn lengthSquared(self: Vec3) f64 {
    return self.x * self.x + self.y * self.y + self.z * self.z;
}

pub fn length(self: Vec3) f64 {
    return @sqrt(self.lengthSquared());
}

pub fn random() Vec3 {
    return .{
        .x = rng.randomDouble(),
        .y = rng.randomDouble(),
        .z = rng.randomDouble(),
    };
}

pub fn randomRange(min: f64, max: f64) Vec3 {
    return .{
        .x = rng.randomDoubleRange(min, max),
        .y = rng.randomDoubleRange(min, max),
        .z = rng.randomDoubleRange(min, max),
    };
}

pub fn unitVector(self: Vec3) Vec3 {
    return self.div(self.length());
}

pub fn randomUnitVector() Vec3 {
    while (true) {
        const p = Vec3.randomRange(-1, 1);
        const lensq = p.lengthSquared();
        if (1e-160 < lensq and lensq <= 1) return p.div(@sqrt(lensq));
    }
}

pub fn randomOnHemisphere(normal: Vec3) Vec3 {
    const on_unit_sphere = randomUnitVector();
    if (dot(on_unit_sphere, normal) > 0.0) { // In the same hemisphere as the normal
        return on_unit_sphere;
    } else {
        return on_unit_sphere.scale(-1);
    }
}

pub fn reflect(v: Vec3, n: Vec3) Vec3 {
    return v.sub(n.scale(2 * dot(v, n)));
}

pub fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
    const cos_theta = @min(dot(uv.scale(-1), n), 1.0);
    const r_out_perp = uv.add(n.scale(cos_theta)).scale(etai_over_etat);
    const r_out_parallel = n.scale(-@sqrt(@abs(1.0 - r_out_perp.lengthSquared())));
    return r_out_perp.add(r_out_parallel);
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
