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
pub const Config = struct {
    aspect_ratio: f64 = 16.0 / 9.0,
    image_height: u32 = 720,
    samples_per_pixel: u32 = 128,
    max_depth: u32 = 64,
    vfov: f64 = 90.0,
    lookfrom: Point3 = .{ .x = 0, .y = 0, .z = 1 },
    lookat: Point3 = .{ .x = 0, .y = 0, .z = -1 },
    vup: Vec3 = .{ .x = 0, .y = 1, .z = 0 },
    defocus_angle: f64 = 0,
    focus_dist: f64 = 10,
};

// --- Derived State / Private fields ---
config: Config = .{},

image_width: u32 = undefined,
pixel_samples_scale: f64 = undefined,
center: Point3 = undefined,
pixel00_loc: Point3 = undefined,
pixel_delta_u: Vec3 = undefined,
pixel_delta_v: Vec3 = undefined,
defocus_disk_u: Vec3 = undefined,
defocus_disk_v: Vec3 = undefined,

pub fn init(config: Config) Camera {
    var result: Camera = undefined;
    result.config = config;
    result.center = config.lookfrom;

    const height_f = @as(f64, @floatFromInt(config.image_height));
    const width = @max(1, @as(u32, @intFromFloat(@trunc(height_f * config.aspect_ratio))));
    // const focal_length = config.lookfrom.sub(config.lookat).length();
    const h = std.math.tan(std.math.degreesToRadians(config.vfov) / 2.0);
    const viewport_height = 2.0 * h * config.focus_dist;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(width)) / height_f);
    const w = config.lookfrom.sub(config.lookat).unitVector();
    const u = Vec3.cross(config.vup, w).unitVector();
    const v = Vec3.cross(w, u);
    const viewport_u = u.scale(viewport_width);
    const viewport_v = v.scale(-viewport_height);
    const delta_u = viewport_u.div(@as(f64, @floatFromInt(width)));
    const delta_v = viewport_v.div(height_f);
    const viewport_upper_left = result.center.sub(w.scale(config.focus_dist)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
    result.pixel00_loc = viewport_upper_left.add(delta_u.add(delta_v).scale(0.5));
    // Might have to reorder these

    // Calculate the camera defocus disk basis vectors.
    const defocus_radius = config.focus_dist * @tan(std.math.degreesToRadians(config.defocus_angle / 2));
    result.defocus_disk_u = u.scale(defocus_radius);
    result.defocus_disk_v = v.scale(defocus_radius);

    result.image_width = width;
    result.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(config.samples_per_pixel));
    result.pixel00_loc = viewport_upper_left.add(delta_u.add(delta_v).scale(0.5));
    result.pixel_delta_u = delta_u;
    result.pixel_delta_v = delta_v;

    return result;
}

pub fn render(self: *const Camera, world: HittableList, writer: *std.Io.Writer) !void {
    try writer.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.config.image_height });

    for (0..self.config.image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{self.config.image_height - j});
        for (0..self.image_width) |i| {
            var pixel_color: Color = .{};
            for (0..self.config.samples_per_pixel) |_| {
                const r = self.getRay(i, j);
                pixel_color = pixel_color.add(self.rayColor(r, self.config.max_depth, .{ .list = world }));
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
    // Construct a camera ray originating from the defocus disk and directed at a randomly
    // sampled point around the pixel location i, j.

    const offset = sampleSquare();
    const pixel_sample = self.pixel00_loc
        .add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x))
        .add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

    const ray_origin = if (self.config.defocus_angle <= 0) self.center else defocusDiskSample(self);
    const ray_direction = pixel_sample.sub(ray_origin);

    return .{ .orig = ray_origin, .dir = ray_direction };
}

fn sampleSquare() Vec3 {
    return .{ .x = random.randomDouble() - 0.5, .y = random.randomDouble() - 0.5, .z = 0 };
}

fn defocusDiskSample(self: *const Camera) Point3 {
    // Returns a random point in the camera defocus disk.
    const p = Vec3.randomInUnitDisk();
    return self.center
        .add(self.defocus_disk_u.scale(p.x))
        .add(self.defocus_disk_v.scale(p.y));
}
