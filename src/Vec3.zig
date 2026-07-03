const std = @import("std");
const rng = @import("random.zig");

e: [3]f64 = .{ 0, 0, 0 },

const Vec3 = @This();
pub const Point3 = Vec3;

// --- Namespace Functions (Operate on two distinct inputs) ---
// (Can also be used as methods)

pub fn add(u: Vec3, v: Vec3) Vec3 {
    return .{ .e = .{ u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2] } };
}

pub fn sub(u: Vec3, v: Vec3) Vec3 {
    return .{ .e = .{ u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2] } };
}

pub fn mul(u: Vec3, v: Vec3) Vec3 {
    return .{ .e = .{ u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2] } };
}

pub fn dot(u: Vec3, v: Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return .{
        .e = .{
            u.e[1] * v.e[2] - u.e[2] * v.e[1],
            u.e[2] * v.e[0] - u.e[0] * v.e[2],
            u.e[0] * v.e[1] - u.e[1] * v.e[0],
        },
    };
}

// --- Method Functions (Operate on the instance itself) ---
// (Intended to be used as methods)

pub fn nearZero(self: Vec3) bool {
    const s = 1e-8;
    return @abs(self.e[0]) < s and @abs(self.e[1]) < s and @abs(self.e[2]) < s;
}

pub fn scale(self: Vec3, t: f64) Vec3 {
    return .{ .e = .{ self.e[0] * t, self.e[1] * t, self.e[2] * t } };
}

pub fn div(self: Vec3, t: f64) Vec3 {
    return self.scale(1.0 / t);
}

pub fn lengthSquared(self: Vec3) f64 {
    return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
}

pub fn length(self: Vec3) f64 {
    return @sqrt(self.lengthSquared());
}

pub fn random() Vec3 {
    return .{
        .e = .{
            rng.randomDouble(),
            rng.randomDouble(),
            rng.randomDouble(),
        },
    };
}

pub fn randomRange(min: f64, max: f64) Vec3 {
    return .{
        .e = .{
            rng.randomDoubleRange(min, max),
            rng.randomDoubleRange(min, max),
            rng.randomDoubleRange(min, max),
        },
    };
}

pub fn unitVector(self: Vec3) Vec3 {
    return self.div(self.length());
}

pub fn randomInUnitDisk() Vec3 {
    while (true) {
        const p: Vec3 = .{
            .e = .{
                rng.randomDoubleRange(-1, 1),
                rng.randomDoubleRange(-1, 1),
                0,
            },
        };
        if (p.lengthSquared() < 1) return p;
    }
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
    try writer.print("{d} {d} {d}", .{ self.e[0], self.e[1], self.e[2] });
}
