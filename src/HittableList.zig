const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const hittable = @import("hittable.zig");
const HitRecord = hittable.HitRecord;

objects: std.ArrayList(hittable.Hittable) = .empty,

const HittableList = @This();

pub fn deinit(self: *HittableList, allocator: std.mem.Allocator) void {
    self.objects.deinit(allocator);
}

pub fn add(self: *HittableList, allocator: std.mem.Allocator, object: hittable.Hittable) !void {
    try self.objects.append(allocator, object);
}

pub fn hit(self: HittableList, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    var temp_rec: HitRecord = undefined;
    var hit_anything: bool = false;
    var closest_so_far = ray_tmax;

    for (self.objects.items) |object| {
        if (object.hit(r, ray_tmin, closest_so_far, &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec.* = temp_rec;
        }
    }
    return hit_anything;
}
