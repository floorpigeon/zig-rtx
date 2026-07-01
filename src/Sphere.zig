const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Point3 = Vec3.Point3;
const HitRecord = @import("hittable.zig").HitRecord;
const Interval = @import("Interval.zig");
const Material = @import("material.zig").Material;

center: Point3,
radius: f64,
mat: Material,

const Sphere = @This();

pub fn init(center: Point3, radius: f64) Sphere {
    return .{ .center = center, .radius = @max(0, radius) };
}

pub fn hit(self: Sphere, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
    const oc = Vec3.sub(self.center, r.orig);
    const a = r.dir.lengthSquared();
    const h = Vec3.dot(r.dir, oc);
    const c = oc.lengthSquared() - self.radius * self.radius;

    const discriminant = h * h - a * c;
    if (discriminant < 0) return false;

    const sqrtd = @sqrt(discriminant);

    // Find the nearest root in the acceptable range
    var root = (h - sqrtd) / a;
    if (!ray_t.surrounds(root)) {
        root = (h + sqrtd) / a;
        if (!ray_t.surrounds(root)) return false;
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    const outward_normal = Vec3.sub(rec.p, self.center).div(self.radius);
    rec.setFaceNormal(r, outward_normal);
    rec.mat = self.mat;

    return true;
}
