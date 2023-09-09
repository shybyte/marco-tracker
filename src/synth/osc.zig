const std = @import("std");
const SAMPLE_RATE = @import("../constants.zig").SAMPLE_RATE;

const OscType = enum { sin, saw, square, triangle };

pub const Osc = struct {
    oscType: OscType = OscType.saw,
    time: f32 = 0,
    keep_time_counter: f32 = 0,
    keep_time: f32 = 2000,
    skip_time: f32 = 0,

    const Self = @This();

    pub fn generate(self: *@This(), freq: f32) f32 {
        self.time += freq / SAMPLE_RATE;

        if (self.skip_time > 0) {
            self.keep_time_counter += 1;
            if (self.keep_time_counter > self.keep_time) {
                self.keep_time_counter = 0;
                self.time += self.skip_time * freq / SAMPLE_RATE;
            }
        }

        if (self.time > 1) {
            self.time = @mod(self.time, 1);
        }

        return switch (self.oscType) {
            .sin => generateSin(self.time),
            .saw => generateSaw(self.time),
            .square => generateSquare(self.time),
            .triangle => generateTri(self.time),
        };
    }
};

fn generateSin(time: f32) f32 {
    return @sin(time * std.math.pi * 2);
}

fn generateSquare(x: f32) f32 {
    if (generateSin(x) < 0) {
        return -1;
    }
    return 1;
}

fn generateSaw(x: f32) f32 {
    return @mod(x, 1) - 0.5;
}

fn generateTri(x: f32) f32 {
    const v2 = @mod(x, 1) * 4;
    if (v2 < 2) {
        return v2 - 1;
    }
    return 3 - v2;
}
