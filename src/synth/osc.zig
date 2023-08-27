const std = @import("std");
const SAMPLE_RATE = @import("../constants.zig").SAMPLE_RATE;

fn generateSin(time: f32) f32 {
    return @sin(time * std.math.pi * 2);
}

pub const SinOsc = struct {
    time: f32 = 0,

    const Self = @This();

    pub fn generate(self: *@This(), freq: f32) f32 {
        self.time += freq / SAMPLE_RATE;
        return generateSin(self.time);
    }
};
