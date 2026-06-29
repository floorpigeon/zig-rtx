const std = @import("std");
const color = @import("color.zig");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Color = color.Color;
const Point3 = Vec3.Point3;

const zig_rtx = @import("zig_rtx");

const aspect_ratio = 16.0 / 9.0;

const image_width = 400;

// Calculate the image height and make sure its at least 1
const image_height = @max(1, @as(u32, @trunc(@as(f64, image_width) / aspect_ratio)));

// Camera
const focal_length = 1.0;
const viewport_height = 2.0;
const viewport_width = viewport_height * (@as(f64, image_width) / image_height);
const camera_center: Point3 = .{};

// Calculate the vectors across the horisontal and down the vertical viewpower edges.
const viewport_u: Vec3 = .{ .x = viewport_width };
const viewport_v: Vec3 = .{ .y = -viewport_height };

// Calculate the horizontal and vertical delta vectors from pixel to pixel
const pixel_delta_u = viewport_u.div(image_width);
const pixel_delta_v = viewport_v.div(image_height);

// Calculate the location of the upper left pixel.
const viewport_upper_left = camera_center.sub(.{ .z = focal_length }).sub(viewport_u.div(2)).sub(viewport_v.div(2));
const pixel00_loc = viewport_upper_left.add(Vec3.add(pixel_delta_u, pixel_delta_v).scale(0.5));

fn rayColor(r: Ray) Vec3 {
    const unit_direction = r.dir.unitVector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return .{
        .x = std.math.lerp(@as(f64, 1.0), @as(f64, 0.5), a),
        .y = std.math.lerp(@as(f64, 1.0), @as(f64, 0.7), a),
        .z = 1.0,
    };
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var dir = std.Io.Dir.cwd();
    var file = try dir.createFile(io, "image.ppm", .{});
    defer file.close(io);
    var write_buffer: [4096]u8 = undefined;
    var file_writer = file.writer(io, &write_buffer);
    const ppm = &file_writer.interface;

    // Render

    try ppm.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d}: ", .{(image_height - j)});
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc.add(pixel_delta_u.scale(@floatFromInt(i))).add(pixel_delta_v.scale(@floatFromInt(j)));
            const ray_direction = pixel_center.sub(camera_center);
            const r: Ray = .{ .orig = camera_center, .dir = ray_direction };

            const pixel_color = rayColor(r);

            try color.writeColor(ppm, pixel_color);
        }
    }
    std.debug.print("\rDone.                  \n", .{});
    try ppm.flush();
}
