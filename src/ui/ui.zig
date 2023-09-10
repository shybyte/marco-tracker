const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const saudio = sokol.audio;
const sapp = sokol.app;
const sdtx = sokol.debugtext;

const keymap = @import("../keymap.zig");
const synth = @import("../synth/synth.zig");
const song_player = @import("../player.zig");
const Note = @import("../notes.zig").Note;
const draw_pattern = @import("./pattern.zig").drawPattern;
const inst_editor = @import("./inst-editor.zig");
const storage = @import("../storage.zig");
const midi = @import("../midi.zig");
const ui_utils = @import("./utils.zig");

var pattern_edit_row_index: usize = 0;
var row_step: usize = 0;
var octave: u8 = 4;
var edit_mode = true;

const ChainCommand = enum { set_step, set_octave };

var chain_command: ?ChainCommand = null;

var ui_context: ui_utils.Context = .{};

pub fn draw() void {
    draw_pattern(song_player.getCurrentPattern(), song_player.getCurrentPatternPlayingPos(), pattern_edit_row_index);

    const inst = song_player.getSong().instruments[0];
    inst_editor.draw(ui_context, inst);

    sdtx.draw();
}

pub fn onInput(event: ?*const sapp.Event) void {
    const ev = event.?;

    if (ev.type == .MOUSE_MOVE) {
        ui_context.mouse_pos.x = ev.mouse_x;
        ui_context.mouse_pos.y = ev.mouse_y;
    }

    inst_editor.onInput(ui_context, event);

    // std.log.info("modifiers: {}", .{ev.modifiers});
    var current_pattern = song_player.getCurrentPattern();

    if (ev.type == .KEY_DOWN) {
        if (chain_command) |command| {
            switch (command) {
                .set_step => {
                    const key_code_int = @intFromEnum(ev.key_code);
                    if (@intFromEnum(sapp.Keycode._0) <= key_code_int and key_code_int <= @intFromEnum(sapp.Keycode._9)) {
                        row_step = @intCast(key_code_int - @intFromEnum(sapp.Keycode._0));
                        std.log.info("row_step: {}", .{row_step});
                    }
                    chain_command = null;
                },
                .set_octave => {
                    const key_code_int = @intFromEnum(ev.key_code);
                    if (@intFromEnum(sapp.Keycode._0) <= key_code_int and key_code_int <= @intFromEnum(sapp.Keycode._9)) {
                        octave = @intCast(key_code_int - @intFromEnum(sapp.Keycode._0));
                        std.log.info("octave: {}", .{octave});
                    }
                    chain_command = null;
                },
            }
            return;
        }

        if (ev.modifiers == sapp.modifier_alt) {
            switch (ev.key_code) {
                .S => {
                    chain_command = ChainCommand.set_step;
                },
                .O => {
                    chain_command = ChainCommand.set_octave;
                },
                else => {},
            }
            return;
        }

        switch (ev.key_code) {
            .F5 => {
                edit_mode = !edit_mode;
            },
            .UP => {
                pattern_edit_row_index = (pattern_edit_row_index + current_pattern.rows.len - 1) % current_pattern.rows.len;
            },
            .DOWN => {
                pattern_edit_row_index = (pattern_edit_row_index + 1) % current_pattern.rows.len;
            },
            .DELETE => {
                current_pattern.rows[pattern_edit_row_index].note = null;
                pattern_edit_row_index = (pattern_edit_row_index + row_step) % current_pattern.rows.len;
            },
            else => {
                std.log.info("key_code: {}", .{ev.key_code});
                if (keymap.get_note_for_key(ev.key_code, octave)) |note| {
                    onNoteInput(note);
                }
            },
        }
    }
}

pub fn onMidiInput(event: midi.MidiEvent) void {
    // std.log.debug("onMidiInput {}", .{event});
    const note_on_opt = event.getNoteOn();
    if (note_on_opt) |note_on| {
        std.log.debug("NoteOn {}", .{note_on});
        onNoteInput(note_on);
    }
}

pub fn onNoteInput(note: Note) void {
    if (edit_mode) {
        var current_pattern = song_player.getCurrentPattern();
        current_pattern.rows[pattern_edit_row_index].note = note;
        pattern_edit_row_index = (pattern_edit_row_index + row_step) % current_pattern.rows.len;
    }
    synth.playNote(note);
}
