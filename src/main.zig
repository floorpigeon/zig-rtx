const std = @import("std");

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

    var j: u32 = 0;

    while (j < image_height) : (j += 1) {
        var i: u32 = 0;
        while (i < image_width) : (i += 1) {
            const r: f64 = @as(f64, @floatFromInt(i)) / (image_width - 1);
            const g: f64 = @as(f64, @floatFromInt(j)) / (image_height - 1);
            const b: f64 = 0;

            const ir: u32 = @trunc(255.999 * r);
            const ig: u32 = @trunc(255.999 * g);
            const ib: u32 = @trunc(255.999 * b);

            try ppm.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }
    try ppm.flush();
}
