const song = @import("./song.zig");
const synth = @import("./synth/synth.zig");

var current_song = song.EMPTY_SONG;

var current_pos: f32 = 0;

pub fn setSong(song_arg: song.Song) void {
    current_song = song_arg;
}

pub fn getCurrentPattern() song.Pattern {
    return current_song.patterns[0];
}

const pos_delta = 0.00015;

pub fn generate() f32 {
    const rows = getCurrentPattern().rows;
    const current_row_index = @floor(current_pos);
    if (@floor(current_pos - pos_delta) != current_row_index) {
        if (rows[@intFromFloat(current_row_index)].note) |note| {
            synth.playNote(note);
        }
    }
    current_pos += pos_delta;
    if (current_pos >= rows.len) {
        current_pos = 0;
    }
    return synth.generate();
}
