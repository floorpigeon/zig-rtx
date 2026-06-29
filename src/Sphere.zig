const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Point3 = Vec3.Point3;
const HitRecord = @import("Hittable.zig").HitRecord;

center: Point3,
radius: f64,

const Sphere = @This();

pub fn init(center: Point3, radius: f64) Sphere {
    return .{ .center = center, .radius = @max(0, radius) };
}

pub fn hit(self: Sphere, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    const oc = Vec3.sub(self.center, r.orig);
    const a = r.dir.lengthSquared();
    const h = Vec3.dot(r.dir, oc);
    const c = oc.lengthSquared() - self.radius * self.radius;

    const discriminant = h * h - a * c;
    if (discriminant < 0) return false;

    const sqrtd = @sqrt(discriminant);

    // Find the nearest root in the acceptable range
    var root = (h - sqrtd) / a;
    if (root <= ray_tmin or ray_tmax <= root) {
        root = (h + sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) return false;
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    rec.normal = Vec3.sub(rec.p, self.center).div(self.radius);

    return true;
}
