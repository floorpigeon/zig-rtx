const std = @import("std");
const Vec3 = @import("Vec3.zig");

pub const Color = Vec3;

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    const r: u8 = @trunc(255.999 * pixel_color.x);
    const g: u8 = @trunc(255.999 * pixel_color.y);
    const b: u8 = @trunc(255.999 * pixel_color.z);
    try writer.print("{d} {d} {d}\n", .{ r, g, b });
}
