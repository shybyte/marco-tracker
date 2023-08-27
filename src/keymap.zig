const sokol = @import("sokol");
const sapp = sokol.app;
const notes = @import("./notes.zig");

const C4 = notes.A4 - 12 + 3;

pub fn get_note_for_key(key_code: sapp.Keycode) ?notes.Note {
    return switch (key_code) {
        .Y => C4,
        .S => C4 + 1,
        .X => C4 + 2,
        .D => C4 + 3,
        .C => C4 + 4,
        else => null,
    };
}
