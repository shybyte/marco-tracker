const notes = @import("../notes.zig");
const std = @import("std");
const Note = notes.Note;

const Adsr = @import("./envelops.zig").Adsr;
const Osc = @import("./osc.zig").Osc;

var current_note: Note = notes.A4;

var adsr: Adsr = Adsr{};
var osc: Osc = Osc{};

pub fn playNote(note: Note) void {
    current_note = note;
    // std.log.info("playNote {}", .{note});
    adsr.trigger();
}

pub fn generate() f32 {
    return osc.generate(notes.midiNoteFrequency(current_note)) * adsr.generate();
}
