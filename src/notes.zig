const std = @import("std");

pub const Note = u8;
pub const A4 = 69;
const A4_FREQ = 440;

pub fn midiNoteFrequency(note: Note) f32 {
    const half_steps = @as(f32, @floatFromInt(note)) - 69.0;
    return A4_FREQ * std.math.pow(f32, 2.0, half_steps / 12.0);
}
