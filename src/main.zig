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
const material = @import("material.zig");
const Material = material.Material;

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

    const material_ground: Material = .{ .lambertian = .{ .albedo = .{ .x = 0.8, .y = 0.8, .z = 0.0 } } };
    const material_center: Material = .{ .lambertian = .{ .albedo = .{ .x = 0.1, .y = 0.2, .z = 0.5 } } };
    const material_left: Material = .{ .dielectric = .{ .refraction_index = 1.50 } };
    const material_bubble: Material = .{ .dielectric = .{ .refraction_index = 1.00 / 1.50 } };
    const material_right: Material = .{ .metal = .{ .albedo = .{ .x = 0.8, .y = 0.6, .z = 0.2 }, .fuzz = 1.0 } };

    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = 0.0, .y = -100.5, .z = -1.0 }, .radius = 100.0, .mat = material_ground } });
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = 0.0, .y = 0.0, .z = -1.2 }, .radius = 0.5, .mat = material_center } });
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = -1.0, .y = 0.0, .z = -1.0 }, .radius = 0.5, .mat = material_left } });
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = -1.0, .y = 0.0, .z = -1.0 }, .radius = 0.4, .mat = material_bubble } });
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = 1.0, .y = 0.0, .z = -1.0 }, .radius = 0.5, .mat = material_right } });

    const camera = Camera.init(.{
        .vfov = 90,
        .lookfrom = .{ .x = -2, .y = 2, .z = 1 },
        .lookat = .{ .z = -1 },
        .vup = .{ .y = 1 },
    });
    try camera.render(world, ppm);
    try ppm.flush();
}
