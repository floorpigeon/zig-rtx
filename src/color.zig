const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Interval = @import("Interval.zig");

pub const Color = Vec3;

pub fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0) return @sqrt(linear_component);
    return 0;
}

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    var r = pixel_color.e[0];
    var g = pixel_color.e[1];
    var b = pixel_color.e[2];

    // Apply a linear to gamma transform for gamma 2
    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    // Translate the [0,1] component values into their byte range [0,255]
    const intensity: Interval = .{ .min = 0.000, .max = 0.999 };
    const rbyte: u8 = @trunc(256 * intensity.clamp(r));
    const gbyte: u8 = @trunc(256 * intensity.clamp(g));
    const bbyte: u8 = @trunc(256 * intensity.clamp(b));

    // Write out the pixel color components.
    try writer.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}
