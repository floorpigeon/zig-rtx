const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Point3 = Vec3.Point3;
const Ray = @import("Ray.zig");
const HittableList = @import("HittableList.zig");
const Interval = @import("Interval.zig");
const material = @import("material.zig");
const Material = material.Material;

const Sphere = @import("Sphere.zig");

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    mat: Material,
    t: f64,
    front_face: bool,

    pub fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        // Sets the hit record normal vector.
        // NOTE: the parameter 'outward_normal' is assumed to have unit length

        self.front_face = Vec3.dot(r.direction, outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else Vec3.sub(.{}, outward_normal);
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,
    list: HittableList,

    pub fn hit(self: Hittable, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        return switch (self) {
            inline else => |h| h.hit(r, ray_t, rec),
        };
    }
};
