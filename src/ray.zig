const Vec3 = @import("Vec3.zig");
const Point3 = Vec3.Point3;

orig: Point3,
dir: Vec3,

const Ray = @This();

// Mirrors the mathematical function P(t)
pub fn at(self: Ray, t: f64) Point3 {
    return self.orig.add(self.dir.scale(t));
}
