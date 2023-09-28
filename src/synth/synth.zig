const notes = @import("../notes.zig");
const std = @import("std");
const Note = notes.Note;

const Adsr = @import("./envelops.zig").Adsr;
const Osc = @import("./osc.zig").Osc;
const Instrument = @import("../song.zig").Instrument;

pub const Voice = struct {
    current_note: Note = notes.A4,
    adsr: Adsr = Adsr{},
    osc: Osc = Osc{},
};

var voice_1 = Voice{};
var voice_2 = Voice{};
var voice_3 = Voice{};
var voice_4 = Voice{};

pub var voices: [4]*Voice = [_]*Voice{ &voice_1, &voice_2, &voice_3, &voice_4 };

pub fn playNote(note: Note, channel: usize) void {
    var voice = voices[channel];
    voice.current_note = note;
    voice.adsr.trigger();
    // std.log.info("playNote {}", .{note});
}

pub fn setInstrument(inst: *const Instrument, voice_index: usize) void {
    var voice = voices[voice_index];
    voice.osc.osc_type = inst.osc_type;
    voice.adsr.attack_time = inst.adsr_attack;
    voice.adsr.release_time = inst.adsr_release;
}

pub fn generate() f32 {
    var signal: f32 = 0;
    for (voices) |voice| {
        signal += voice.osc.generate(notes.midiNoteFrequency(voice.current_note)) * voice.adsr.generate();
    }
    return signal;
}
