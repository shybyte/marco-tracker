const song_module = @import("./song.zig");
const synth = @import("./synth/synth.zig");

var current_song = song_module.EMPTY_SONG;
var is_playing = true;
var current_pos: f32 = 0;

pub fn setSong(song_arg: song_module.Song) void {
    current_song = song_arg;
    for (song_arg.instruments) |instrument| {
        synth.setInstrument(&instrument);
    }
}

pub fn getSong() *song_module.Song {
    return &current_song;
}

pub fn start() void {
    is_playing = true;
    current_pos = 0;
}

pub fn stop() void {
    is_playing = false;
}

pub fn togglePlaying() void {
    is_playing = !is_playing;
}

pub fn getCurrentPattern() *song_module.Pattern {
    return &current_song.patterns[0];
}

pub fn getCurrentPatternPlayingPos() usize {
    return @intFromFloat(current_pos);
}

const pos_delta = 0.00018;

fn generate() f32 {
    if (!is_playing) {
        return synth.generate();
    }

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

pub fn audio_stream_callback(buffer: [*c]f32, num_frames: i32, num_channels: i32) callconv(.C) void {
    _ = num_channels;
    for (0..@intCast(num_frames)) |i| {
        const signal = generate();
        buffer[2 * i] = signal;
        buffer[2 * i + 1] = signal;
    }
}
