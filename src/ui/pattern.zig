const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sdtx = sokol.debugtext;
const notes = @import("../notes.zig");
const song = @import("../song.zig");

const FONT_SCALE_FACTOR = 2;

pub fn drawPattern(pattern: song.Pattern) void {
    std.log.debug("Width/Height: {d} {d}", .{ sapp.widthf(), sapp.heightf() });
    sdtx.canvas(sapp.widthf() / FONT_SCALE_FACTOR, sapp.heightf() / FONT_SCALE_FACTOR);
    sdtx.origin(0, 0);

    sdtx.home();

    for (pattern.rows) |row| {
        if (row.note) |note| {
            drawNote(note);
        } else {
            sdtx.print("--\n", .{});
        }
    }

    sdtx.draw();
}

const NOTE_NAMES: [12]u8 = .{ 'C', 'c', 'D', 'd', 'E', 'F', 'f', 'G', 'g', 'A', 'B', 'H' };

pub fn drawNote(note: notes.Note) void {
    sdtx.print("{c}{d}\n", .{ NOTE_NAMES[note % 12], (note) / 12 - 1 });
}
