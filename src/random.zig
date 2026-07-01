const std = @import("std");

var prng = std.Random.DefaultPrng.init(0);
const random = prng.random();

/// Returns a random real in [0,1).
pub fn randomDouble() f64 {
    return random.float(f64);
}

/// Returns a random real in [min,max).
pub fn randomDoubleRange(min: f64, max: f64) f64 {
    return min + (max - min) * randomDouble();
}
