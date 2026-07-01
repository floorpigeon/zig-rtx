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

const aspect_ratio = 16.0 / 9.0;

const image_height = 360;

// Calculate the image height and make sure its at least 1
const image_width = @max(1, @as(u32, @trunc(@as(f64, image_height) * aspect_ratio)));
const samples_per_pixel = 10;
const pixel_samples_scale = 1.0 / @as(f64, samples_per_pixel);

// Camera
const focal_length = 1.0;
const viewport_height = 2.0;
const viewport_width = viewport_height * (@as(f64, image_width) / image_height);
const center: Point3 = .{};

// Calculate the vectors across the horisontal and down the vertical viewpower edges.
const viewport_u: Vec3 = .{ .x = viewport_width };
const viewport_v: Vec3 = .{ .y = -viewport_height };

// Calculate the horizontal and vertical delta vectors from pixel to pixel
const pixel_delta_u = viewport_u.div(image_width);
const pixel_delta_v = viewport_v.div(image_height);

// Calculate the location of the upper left pixel.
const viewport_upper_left = center.sub(.{ .z = focal_length }).sub(viewport_u.div(2)).sub(viewport_v.div(2));
const pixel00_loc = viewport_upper_left.add(Vec3.add(pixel_delta_u, pixel_delta_v).scale(0.5));

pub fn render(world: HittableList, writer: *std.Io.Writer) !void {
    try writer.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d}: ", .{(image_height - j)});
        for (0..image_width) |i| {
            var pixel_color: Color = .{};
            for (0..samples_per_pixel) |_| {
                const r = getRay(i, j);
                pixel_color = pixel_color.add(rayColor(r, .{ .list = world }));
            }
            try color.writeColor(writer, pixel_color.scale(pixel_samples_scale));
        }
    }
    std.debug.print("\rDone.                  \n", .{});
    try writer.flush();
}

fn rayColor(r: Ray, world: Hittable) Color {
    var rec: hittable.HitRecord = undefined;
    if (world.hit(r, .{ .min = 0, .max = Interval.universe.max }, &rec)) {
        return rec.normal.add(Color{
            .x = 1,
            .y = 1,
            .z = 1,
        }).scale(0.5);
    }

    const unit_direction = r.dir.unitVector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return .{
        .x = std.math.lerp(@as(f64, 1.0), @as(f64, 0.5), a),
        .y = std.math.lerp(@as(f64, 1.0), @as(f64, 0.7), a),
        .z = 1.0,
    };
}

fn getRay(i: usize, j: usize) Ray {
    // Construct a camera ray originating from the origin and directed as a
    // randomly sampled point around the pixel location i, j.
    const offset = sampleSquare();
    const pixel_sample = pixel00_loc.add(pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x)).add(pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

    const ray_origin = center;
    const ray_direction = pixel_sample.sub(ray_origin);

    return .{ .orig = ray_origin, .dir = ray_direction };
}

fn sampleSquare() Vec3 {
    // Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
    return .{ .x = random.randomDouble() - 0.5, .y = random.randomDouble() - 0.5, .z = 0 };
}
