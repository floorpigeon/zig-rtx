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
const rng = @import("random.zig");

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

    const ground_material: Material = .{ .lambertian = .{ .albedo = .{ .x = 0.5, .y = 0.5, .z = 0.5 } } };
    try world.add(allocator, .{ .sphere = .{ .center = .{ .y = -1000 }, .radius = 1000, .mat = ground_material } });

    var a: f64 = -11;
    while (a < 11) : (a += 1) {
        var b: f64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = rng.randomDouble();
            const center: Point3 = .{ .x = a + 0.9 * rng.randomDouble(), .y = 0.2, .z = b + 0.9 * rng.randomDouble() };

            if (center.sub(.{ .x = 4, .y = 0.2 }).length() > 0.9) {
                var sphere_material: Material = undefined;

                if (choose_mat < 0.8) {
                    // difuse
                    const albedo = Color.random().mul(Color.random());
                    sphere_material = .{ .lambertian = .{ .albedo = albedo } };
                    try world.add(allocator, .{ .sphere = .{ .center = center, .radius = 0.2, .mat = sphere_material } });
                } else if (choose_mat < 0.95) {
                    // metal
                    const albedo = Color.randomRange(0.5, 1);
                    const fuzz = rng.randomDoubleRange(0, 0.5);
                    sphere_material = .{ .metal = .{ .albedo = albedo, .fuzz = fuzz } };
                    try world.add(allocator, .{ .sphere = .{ .center = center, .radius = 0.2, .mat = sphere_material } });
                } else {
                    // glass
                    sphere_material = .{ .dielectric = .{ .refraction_index = 1.5 } };
                    try world.add(allocator, .{ .sphere = .{ .center = center, .radius = 0.2, .mat = sphere_material } });
                }
            }
        }
    }
    const material1: Material = .{ .dielectric = .{ .refraction_index = 1.5 } };
    try world.add(allocator, .{ .sphere = .{ .center = .{ .y = 1 }, .radius = 1, .mat = material1 } });

    const material2: Material = .{ .lambertian = .{ .albedo = .{ .x = 0.4, .y = 0.2, .z = 0.1 } } };
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = -4, .y = 1 }, .radius = 1, .mat = material2 } });

    const material3: Material = .{ .metal = .{ .albedo = .{ .x = 0.7, .y = 0.6, .z = 0.5 }, .fuzz = 0 } };
    try world.add(allocator, .{ .sphere = .{ .center = .{ .x = 4, .y = 1 }, .radius = 1, .mat = material3 } });

    const camera = Camera.init(.{
        .aspect_ratio = 16.0 / 9.0,
        .image_height = 720,
        .samples_per_pixel = 500,
        .max_depth = 50,
        .vfov = 20,
        .lookfrom = .{ .x = 13, .y = 2, .z = 3 },
        .defocus_angle = 0.6,
        .focus_dist = 10,
    });
    try camera.render(world, ppm);
    try ppm.flush();
}
