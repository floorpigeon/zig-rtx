const Vec3 = @import("Vec3.zig");
const Point3 = Vec3.Point3;

orig: Point3,
dir: Vec3,

const Ray = @This();

pub fn at(self: Ray, t: f64) Point3 {
    // P(t) = A + tb
    // Here P is a 3D position along a line in 3D. A is the ray origin and b is the ray direction.
    // The ray parameter t is a real number (f64 in the code).
    // Plug in a different t and P(t) moves the point along the ray.
    // Add in negative t values and you can go anywhere on the 3D line.
    // For positive t, you get only the parts in front of A, and this is what is often called a half-line or a ray.
    return self.orig.add(self.dir.scale(t));
}
