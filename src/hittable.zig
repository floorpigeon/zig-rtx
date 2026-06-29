const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Point3 = Vec3.Point3;
const Ray = @import("Ray.zig");

const Sphere = @import("Sphere.zig");

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        return switch (self) {
            inline else => |h| h.hit(r, ray_tmin, ray_tmax, rec),
        };
    }
};
