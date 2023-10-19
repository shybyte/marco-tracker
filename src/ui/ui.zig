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
const song_module = @import("../song.zig");
const Pattern = song_module.Pattern;
const FONT_SCALE_FACTOR = @import("../constants.zig").FONT_SCALE_FACTOR;

var channel_index: usize = 0;
var pattern_edit_row_index: usize = 0;
var row_step: usize = 0;
var octave: u8 = 4;
var edit_mode = true;

const ChainCommand = enum { set_step, set_octave };

var chain_command: ?ChainCommand = null;

var ui_context: ui_utils.Context = .{};

var default_pattern: Pattern = song_module.EMTPY_PATTERN;
var default_inst: song_module.Instrument = .{};

pub fn draw() void {
    const song = song_player.getSong();
    song.ensureTrailingEmptyRow();

    drawSongRows();

    for (song.rows.items[song_player.getCurrentSongRowIndex()].cols, 0..) |pattern_id_opt, i| {
        const pattern_id = pattern_id_opt orelse 0;
        const patterns = song.channels.items[i].patterns.items;
        const pattern = if (pattern_id_opt != null and pattern_id < patterns.len) &patterns[pattern_id] else &default_pattern;
        draw_pattern(
            pattern,
            song_player.getCurrentPatternPlayingPos(),
            pattern_edit_row_index,
            channel_index == i,
            .{ .x = 16 + @as(f32, @floatFromInt(i)) * 3 },
        );
    }

    const instruments = song_player.getSong().instruments.items;
    const inst = if (channel_index < instruments.len) &instruments[channel_index] else &default_inst;
    inst_editor.draw(ui_context, inst, .{ .x = 30 });
    synth.setInstrument(inst, channel_index);

    sdtx.draw();
    ui_context.current_event = null;
}

const SONG_ROWS_POS = ui_utils.Point2D{ .x = 0, .y = 0 };
const EMPTY_SONG_ROW_STRING = "-- ";
const SONG_ROW_WIDTH = EMPTY_SONG_ROW_STRING.len;

pub fn drawSongRows() void {
    // std.log.debug("Width/Height: {d} {d}", .{ sapp.widthf(), sapp.heightf() });
    sdtx.canvas(sapp.widthf() / FONT_SCALE_FACTOR, sapp.heightf() / FONT_SCALE_FACTOR);
    sdtx.origin(SONG_ROWS_POS.x, SONG_ROWS_POS.y);
    var text_pos = SONG_ROWS_POS;

    sdtx.home();

    const song = song_player.getSong();

    for (song.rows.items, 0..) |*row, row_i| {
        for (row.cols, 0..) |col, col_i| {
            if (row_i == song_player.getCurrentSongRowIndex()) {
                sdtx.color3f(1, 1, 1);
            } else if (col_i == channel_index) {
                sdtx.color3f(0.8, 0.8, 0.9);
            } else {
                sdtx.color3f(0.5, 0.5, 0.6);
            }

            const is_under_mouse = ui_utils.is_in_text_rect(ui_context.mouse_pos, text_pos, SONG_ROW_WIDTH);
            if (is_under_mouse) {
                sdtx.color3f(1, 0.3, 1);
                if (ui_context.current_event) |ev| {
                    if (ev.type == .MOUSE_DOWN) {
                        song_player.setCurrentSongRowIndex(row_i);
                        channel_index = col_i;
                    } else if (ev.type == .MOUSE_SCROLL) {
                        var new_pattern_index_opt: ?usize = if (col) |pattern_id|
                            if (ev.scroll_y > 0)
                                pattern_id + 1
                            else if (pattern_id > 0)
                                pattern_id - 1
                            else
                                null
                        else
                            0;
                        if (new_pattern_index_opt) |new_pattern_index| {
                            song.channels.items[col_i].ensurePatternNoReturn(new_pattern_index) catch {};
                        }
                        row.cols[col_i] = new_pattern_index_opt;
                    }
                }
            }

            if (col) |pattern_id| {
                sdtx.print("{d:0>2} ", .{pattern_id});
            } else {
                sdtx.print(EMPTY_SONG_ROW_STRING, .{});
            }

            text_pos.x += SONG_ROW_WIDTH;
        }
        sdtx.crlf();
        text_pos.y += 1;
        text_pos.x = 0;
    }
}

pub fn onInput(event: ?*const sapp.Event) void {
    const ev = event.?;

    ui_context.current_event = ev.*;

    if (ev.type == .MOUSE_MOVE) {
        ui_context.mouse_pos.x = ev.mouse_x;
        ui_context.mouse_pos.y = ev.mouse_y;
    }

    // std.log.info("modifiers: {}", .{ev.modifiers});
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
                pattern_edit_row_index = (pattern_edit_row_index + song_module.PATTEN_LENGTH - 1) % song_module.PATTEN_LENGTH;
            },
            .DOWN => {
                pattern_edit_row_index = (pattern_edit_row_index + 1) % song_module.PATTEN_LENGTH;
            },
            .LEFT => {
                channel_index = (channel_index + song_module.CHANNEL_NUM - 1) % song_module.CHANNEL_NUM;
            },
            .RIGHT => {
                channel_index = (channel_index + 1) % song_module.CHANNEL_NUM;
            },
            .DELETE => {
                if (getCurrentPatternEnsured()) |current_pattern| {
                    current_pattern.rows[pattern_edit_row_index].note = null;
                    pattern_edit_row_index = (pattern_edit_row_index + row_step) % current_pattern.rows.len;
                } else |err| {
                    std.log.err("Error {}", .{err});
                }
            },
            else => {
                std.log.info("key_code: {}", .{ev.key_code});
                if (keymap.get_note_for_key(ev.key_code, octave)) |note| {
                    onNoteInput(note) catch {};
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
        onNoteInput(note_on) catch {};
    }
}

fn getCurrentPatternEnsured() !*Pattern {
    var song = song_player.getSong();
    var channel = &song.channels.items[channel_index];
    var song_row = &song.rows.items[song_player.getCurrentSongRowIndex()];
    const pattern_index = song_row.cols[channel_index] orelse blk: {
        const new_pattern_index = channel.patterns.items.len;
        song_row.cols[channel_index] = new_pattern_index;
        break :blk new_pattern_index;
    };

    return channel.ensurePattern(pattern_index);
}

pub fn onNoteInput(note: Note) !void {
    if (edit_mode) {
        const current_pattern = try getCurrentPatternEnsured();
        current_pattern.rows[pattern_edit_row_index].note = note;

        pattern_edit_row_index = (pattern_edit_row_index + row_step) % current_pattern.rows.len;
    }

    synth.playNote(note, channel_index);
}
