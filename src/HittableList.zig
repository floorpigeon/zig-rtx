const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const hittable = @import("hittable.zig");
const HitRecord = hittable.HitRecord;
const Interval = @import("Interval.zig");

objects: std.ArrayList(hittable.Hittable) = .empty,

const HittableList = @This();

pub fn deinit(self: *HittableList, allocator: std.mem.Allocator) void {
    self.objects.deinit(allocator);
}

pub fn add(self: *HittableList, allocator: std.mem.Allocator, object: hittable.Hittable) !void {
    try self.objects.append(allocator, object);
}

pub fn hit(self: HittableList, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
    var temp_rec: HitRecord = undefined;
    var hit_anything: bool = false;
    var closest_so_far = ray_t.max;

    for (self.objects.items) |object| {
        if (object.hit(r, .{ .min = ray_t.min, .max = closest_so_far }, &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec.* = temp_rec;
        }
    }
    return hit_anything;
}
