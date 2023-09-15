const SAMPLE_RATE = @import("../constants.zig").SAMPLE_RATE_F32;

pub const Adsr = struct {
    time: f32 = 0,
    attack_time: f32 = 0.01,
    decay_time: f32 = 0,
    sustain_level: f32 = 1,
    release_time: f32 = 0.5,

    const Self = @This();

    pub fn trigger(self: *@This()) void {
        self.time = 0.0;
    }

    pub fn generate(self: *@This()) f32 {
        self.time += 1.0 / SAMPLE_RATE;

        if (self.time <= self.attack_time) {
            return self.time / self.attack_time;
        }

        const time_in_decay = self.time - (self.attack_time);
        if (time_in_decay <= self.decay_time) {
            return 1 - time_in_decay / self.decay_time * (1 - self.sustain_level);
        }

        const time_in_release = self.time - (self.attack_time + self.decay_time);
        if (time_in_release <= self.release_time) {
            return self.sustain_level - time_in_release / self.release_time * self.sustain_level;
        }

        return 0;
    }
};
