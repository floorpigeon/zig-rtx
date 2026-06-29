const std = @import("std");
const color = @import("color.zig");
const Vec3 = @import("Vec3.zig");
const Color = color.Color;

const zig_rtx = @import("zig_rtx");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var dir = std.Io.Dir.cwd();
    var file = try dir.createFile(io, "image.ppm", .{});
    defer file.close(io);
    var write_buffer: [4096]u8 = undefined;
    var file_writer = file.writer(io, &write_buffer);
    const ppm = &file_writer.interface;

    // Image
    const image_width = 256;
    const image_height = 256;

    // Render

    try ppm.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d}: ", .{(image_height - j)});
        for (0..image_width) |i| {
            const pixel_color: Color = .{
                .x = @as(f64, @floatFromInt(i)) / @as(f64, image_width - 1),
                .y = @as(f64, @floatFromInt(j)) / @as(f64, image_height - 1),
                .z = 0,
            };
            try color.writeColor(ppm, pixel_color);
        }
    }
    std.debug.print("\rDone.                  \n", .{});
    try ppm.flush();
}
