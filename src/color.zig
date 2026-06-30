const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Interval = @import("Interval.zig");

pub const Color = Vec3;

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    const r = pixel_color.x;
    const g = pixel_color.y;
    const b = pixel_color.z;

    // Translate the [0,1] component values into their byte range [0,255]
    const intensity: Interval = .{ .min = 0.000, .max = 0.999 };
    const rbyte: u8 = @trunc(256 * intensity.clamp(r));
    const gbyte: u8 = @trunc(256 * intensity.clamp(g));
    const bbyte: u8 = @trunc(256 * intensity.clamp(b));

    // Write out the pixel color components.
    try writer.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}
