const std = @import("std");

pub const Note = u8;

pub const C0 = 12;

pub const C1 = 24;
pub const C2 = 36;
pub const F2 = C2 + 5;

pub const A2 = A4 - 24;

pub const C3 = A2 + 3;
pub const D3 = C3 + 2;
pub const F3 = C3 + 5;
pub const A3 = A4 - 12;

pub const C4 = A3 + 3;
pub const Cis4 = C4 + 1;
pub const D4 = C4 + 2;
pub const F4 = C4 + 5;

pub const A4 = 69;

pub const C5 = A4 + 3;
pub const Cis5 = C5 + 1;
pub const D5 = C5 + 2;
pub const F5 = C5 + 5;
pub const A5 = A4 + 12;

pub const C6 = C5 + 12;
pub const D6 = C6 + 2;

const A4_FREQ = 440;

pub fn midiNoteFrequency(note: Note) f32 {
    const half_steps = @as(f32, @floatFromInt(note)) - 69.0;
    return A4_FREQ * std.math.pow(f32, 2.0, half_steps / 12.0);
}
