const std = @import("std");
const color = @import("color.zig");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Color = color.Color;
const Point3 = Vec3.Point3;
const hittable = @import("hittable.zig");
const Hittable = hittable.Hittable;
const HittableList = @import("HittableList.zig");
const Interval = @import("Interval.zig");
const Camera = @import("Camera.zig");

const zig_rtx = @import("zig_rtx");

// Seeding random number generator
// Seeding with 0 is deterministic
var prng = std.Random.DefaultPrng.init(0);
const random = prng.random();

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var dir = std.Io.Dir.cwd();
    var file = try dir.createFile(io, "image.ppm", .{});
    defer file.close(io);
    var write_buffer: [4096]u8 = undefined;
    var file_writer = file.writer(io, &write_buffer);
    const ppm = &file_writer.interface;

    // World

    var world: HittableList = .{};
    defer world.deinit(allocator);

    try world.add(allocator, .{ .sphere = .{ .center = .{ .z = -1 }, .radius = 0.5 } });
    try world.add(allocator, .{ .sphere = .{ .center = .{ .y = -100.5, .z = -1 }, .radius = 100 } });

    try Camera.render(world, ppm);
}
