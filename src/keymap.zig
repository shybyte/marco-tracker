const sokol = @import("sokol");
const sapp = sokol.app;
const notes = @import("./notes.zig");

const BASE_NOTE_LOW = notes.C4;
const BASE_NOTE_HIGH = notes.C5;

pub fn get_note_for_key(key_code: sapp.Keycode) ?notes.Note {
    return switch (key_code) {
        .Y => BASE_NOTE_LOW,
        .S => BASE_NOTE_LOW + 1,
        .X => BASE_NOTE_LOW + 2,
        .D => BASE_NOTE_LOW + 3,
        .C => BASE_NOTE_LOW + 4,
        .V => BASE_NOTE_LOW + 5,
        .G => BASE_NOTE_LOW + 6,
        .B => BASE_NOTE_LOW + 7,
        .H => BASE_NOTE_LOW + 8,
        .N => BASE_NOTE_LOW + 9,
        .J => BASE_NOTE_LOW + 10,
        .M => BASE_NOTE_LOW + 11,

        .Q => BASE_NOTE_HIGH,
        ._2 => BASE_NOTE_HIGH + 1,
        .W => BASE_NOTE_HIGH + 2,
        ._3 => BASE_NOTE_HIGH + 3,
        .E => BASE_NOTE_HIGH + 4,
        .R => BASE_NOTE_HIGH + 5,
        ._5 => BASE_NOTE_HIGH + 6,
        .T => BASE_NOTE_HIGH + 7,
        ._6 => BASE_NOTE_HIGH + 8,
        .Z => BASE_NOTE_HIGH + 9,
        ._7 => BASE_NOTE_HIGH + 10,
        .U => BASE_NOTE_HIGH + 11,

        .I => BASE_NOTE_HIGH + 12,
        ._9 => BASE_NOTE_HIGH + 13,
        .O => BASE_NOTE_HIGH + 14,
        ._0 => BASE_NOTE_HIGH + 15,
        .P => BASE_NOTE_HIGH + 16,

        else => null,
    };
}
