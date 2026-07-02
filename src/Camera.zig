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
const random = @import("random.zig");

const Camera = @This();

// --- User Configurable Inputs ---
// with provided defaults
aspect_ratio: f64,
image_height: u32,
samples_per_pixel: u32,
max_depth: u32,
vfov: f64,
lookfrom: Point3,
lookat: Point3,
vup: Vec3,
defocus_angle: f64,
focus_dist: f64,

// --- Derived State / Private fields ---
image_width: u32,
pixel_samples_scale: f64,
center: Point3,
pixel00_loc: Point3,
pixel_delta_u: Vec3,
pixel_delta_v: Vec3,

defocus_disk_u: Vec3,
defocus_disk_v: Vec3,

pub fn init(config: struct {
    aspect_ratio: f64 = 16.0 / 9.0,
    image_height: u32 = 720,
    samples_per_pixel: u32 = 128,
    max_depth: u32 = 64,
    vfov: f64 = 90.0,
    lookfrom: Point3 = .{ .x = 0, .y = 0, .z = 1 },
    lookat: Point3 = .{ .x = 0, .y = 0, .z = -1 },
    vup: Vec3 = .{ .x = 0, .y = 1, .z = 0 },
}) Camera {
    // 1. Math casts use @floatFromInt with @as inference
    const height_f = @as(f64, @floatFromInt(config.image_height));
    const width_f = @trunc(height_f * config.aspect_ratio);

    // Explicit safety-checked cast back to int
    const width = @max(1, @as(u32, @intFromFloat(width_f)));
    const scale = 1.0 / @as(f64, @floatFromInt(config.samples_per_pixel));

    const center = config.lookfrom;
    const focal_length = config.lookfrom.sub(config.lookat).length();
    const theta = std.math.degreesToRadians(config.vfov);
    const h = std.math.tan(theta / 2.0);

    const viewport_height = 2.0 * h * focal_length;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(width)) / height_f);

    const w = Vec3.unitVector(config.lookfrom.sub(config.lookat));
    const u = Vec3.unitVector(Vec3.cross(config.vup, w));
    const v = Vec3.cross(w, u);

    const viewport_u = u.scale(viewport_width);
    const viewport_v = v.scale(-viewport_height);

    const delta_u = viewport_u.div(@as(f64, @floatFromInt(width)));
    const delta_v = viewport_v.div(height_f);

    const viewport_upper_left = center
        .sub(w.scale(focal_length))
        .sub(viewport_u.div(2.0))
        .sub(viewport_v.div(2.0));

    const p00_loc = viewport_upper_left.add(delta_u.add(delta_v).scale(0.5));

    return .{
        .aspect_ratio = config.aspect_ratio,
        .image_height = config.image_height,
        .samples_per_pixel = config.samples_per_pixel,
        .max_depth = config.max_depth,
        .vfov = config.vfov,
        .lookfrom = config.lookfrom,
        .lookat = config.lookat,
        .vup = config.vup,
        .image_width = width,
        .pixel_samples_scale = scale,
        .center = center,
        .pixel00_loc = p00_loc,
        .pixel_delta_u = delta_u,
        .pixel_delta_v = delta_v,
    };
}

pub fn render(self: *const Camera, world: HittableList, writer: *std.Io.Writer) !void {
    try writer.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });

    for (0..self.image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{self.image_height - j});
        for (0..self.image_width) |i| {
            var pixel_color: Color = .{};
            for (0..self.samples_per_pixel) |_| {
                const r = self.getRay(i, j);
                pixel_color = pixel_color.add(self.rayColor(r, self.max_depth, .{ .list = world }));
            }
            try color.writeColor(writer, pixel_color.scale(self.pixel_samples_scale));
        }
    }
    std.debug.print("\rDone.                  \n", .{});
}

fn rayColor(self: *const Camera, r: Ray, depth: u32, world: Hittable) Color {
    if (depth <= 0) return .{};

    var rec: hittable.HitRecord = undefined;
    if (world.hit(r, .{ .min = 0.001, .max = Interval.universe.max }, &rec)) {
        if (rec.mat.scatter(r, rec)) |result| {
            return Vec3.mul(result.attenuation, self.rayColor(result.scattered, depth - 1, world));
        }
        return Color{};
    }

    const unit_direction = r.dir.unitVector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return .{
        .x = std.math.lerp(@as(f64, 1.0), @as(f64, 0.5), a),
        .y = std.math.lerp(@as(f64, 1.0), @as(f64, 0.7), a),
        .z = 1.0,
    };
}

fn getRay(self: *const Camera, i: usize, j: usize) Ray {
    const offset = sampleSquare();
    const pixel_sample = self.pixel00_loc
        .add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x))
        .add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

    const ray_origin = self.center;
    const ray_direction = pixel_sample.sub(ray_origin);

    return .{ .orig = ray_origin, .dir = ray_direction };
}

fn sampleSquare() Vec3 {
    return .{ .x = random.randomDouble() - 0.5, .y = random.randomDouble() - 0.5, .z = 0 };
}
