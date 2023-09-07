const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const saudio = sokol.audio;
const sapp = sokol.app;

const keymap = @import("../keymap.zig");
const synth = @import("../synth/synth.zig");
const song_player = @import("../player.zig");
const draw_pattern = @import("./pattern.zig").drawPattern;

var pattern_edit_row_index: usize = 0;
var row_step: usize = 0;
var octave: u8 = 4;
var edit_mode = true;

const ChainCommand = enum { set_step, set_octave };

var chain_command: ?ChainCommand = null;

pub fn draw() void {
    draw_pattern(song_player.getCurrentPattern(), song_player.getCurrentPatternPlayingPos(), pattern_edit_row_index);
}

pub fn onInput(event: ?*const sapp.Event) void {
    const ev = event.?;
    std.log.info("modifiers: {}", .{ev.modifiers});
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
                .W => {
                    saveFile() catch |err| {
                        std.log.debug("Error {}", .{err});
                    };
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
                    if (edit_mode) {
                        current_pattern.rows[pattern_edit_row_index].note = note;
                        pattern_edit_row_index = (pattern_edit_row_index + row_step) % current_pattern.rows.len;
                    }
                    synth.playNote(note);
                }
            },
        }
    }
}

fn saveFile() !void {
    var string_buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer string_buffer.deinit();

    try std.json.stringify(song_player.getSong(), .{ .whitespace = .indent_2 }, string_buffer.writer());
    const json_string = try string_buffer.toOwnedSlice();
    std.log.debug("json {s}", .{json_string});

    const file = try std.fs.cwd().createFile(
        "songs/system.json",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(json_string);
}
