const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Color = Vec3;
const HitRecord = @import("hittable.zig").HitRecord;

pub const ScatterResult = struct {
    attenuation: Color,
    scattered: Ray,
};

// Remember these return an optional type instead of a boolean
// and do not mutate the instance directly, unlike in the
// tutorial

pub const Lambertian = struct {
    albedo: Color,
    pub fn scatter(self: Lambertian, r_in: Ray, rec: HitRecord) ?ScatterResult {
        _ = r_in;
        var scatter_direction = Vec3.add(rec.normal, Vec3.randomUnitVector());
        if (scatter_direction.nearZero()) scatter_direction = rec.normal;
        return .{
            .attenuation = self.albedo,
            .scattered = .{ .orig = rec.p, .dir = scatter_direction },
        };
    }
};

pub const Metal = struct {
    albedo: Color,
    // Might have to implement the equivalent of this C++ constructor??
    // metal(const color& albedo, double fuzz) : albedo(albedo), fuzz(fuzz < 1 ? fuzz : 1) {}
    fuzz: f64,
    pub fn scatter(self: Metal, r_in: Ray, rec: HitRecord) ?ScatterResult {
        var reflected = Vec3.reflect(r_in.dir, rec.normal);
        reflected = Vec3.unitVector(reflected).add(Vec3.randomUnitVector().scale(self.fuzz));
        const scattered: Ray = .{ .orig = rec.p, .dir = reflected };
        if (Vec3.dot(scattered.dir, rec.normal) < 0) return null;
        return .{ .attenuation = self.albedo, .scattered = scattered };
    }
};

pub const Dielectric = struct {
    refraction_index: f64,
    pub fn scatter(self: Dielectric, r_in: Ray, rec: HitRecord) ?ScatterResult {
        const attenuation = Color{ .x = 1.0, .y = 1.0, .z = 1.0 };
        const ri: f64 = if (rec.front_face) 1.0 / self.refraction_index else self.refraction_index;
        const unit_direction = Vec3.unitVector(r_in.dir);
        const refracted = Vec3.refract(unit_direction, rec.normal, ri);

        return .{ .attenuation = attenuation, .scattered = .{ .orig = rec.p, .dir = refracted } };
    }
};

pub const Material = union(enum) {
    // Variants go here:

    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: Material, r_in: Ray, rec: HitRecord) ?ScatterResult {
        return switch (self) {
            inline else => |m| m.scatter(r_in, rec),
        };
    }
};
