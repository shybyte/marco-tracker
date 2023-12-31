const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sdtx = sokol.debugtext;
const notes = @import("../notes.zig");
const song = @import("../song.zig");
const utils = @import("utils.zig");
const Point2D = utils.Point2D;

const FONT_SCALE_FACTOR = 2;

pub fn drawPattern(pattern: *song.Pattern, playing_row: usize, pattern_edit_row_index: usize, is_current_channel: bool, screen_pos: Point2D) void {
    // std.log.debug("Width/Height: {d} {d}", .{ sapp.widthf(), sapp.heightf() });
    sdtx.canvas(sapp.widthf() / FONT_SCALE_FACTOR, sapp.heightf() / FONT_SCALE_FACTOR);
    sdtx.origin(screen_pos.x, screen_pos.y);

    sdtx.home();

    for (pattern.rows, 0..) |row, i| {
        if (i == pattern_edit_row_index and is_current_channel) {
            sdtx.color3f(1, 1, 0.2);
        } else if (i == playing_row) {
            sdtx.color3f(1, 1, 1);
        } else if (i % 4 == 0) {
            sdtx.color3f(0.8, 0.8, 0.8);
        } else {
            sdtx.color3f(0.5, 0.5, 0.6);
        }

        if (row.note) |note| {
            drawNote(note);
        } else {
            sdtx.print("--\n", .{});
        }
    }
}

const NOTE_NAMES: [12]u8 = .{ 'C', 'c', 'D', 'd', 'E', 'F', 'f', 'G', 'g', 'A', 'B', 'H' };

pub fn drawNote(note: notes.Note) void {
    sdtx.print("{c}{d}\n", .{ NOTE_NAMES[note % 12], (note) / 12 - 1 });
}
