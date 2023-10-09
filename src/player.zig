const std = @import("std");
const song_module = @import("./song.zig");
const synth = @import("./synth/synth.zig");

pub const PlayMode = enum {
    complete,
    row,
};

var current_song: song_module.Song = undefined;
var is_playing = true;

var playmode = PlayMode.complete;
var song_row_index: usize = 0;
var current_pos_in_pattern: f32 = 0;

pub fn setSong(song_arg: song_module.Song) void {
    current_song = song_arg;
    for (song_arg.instruments.items, 0..) |instrument, i| {
        synth.setInstrument(&instrument, i);
    }
}

pub fn getSong() *song_module.Song {
    return &current_song;
}

pub fn start(playmode_arg: PlayMode) void {
    is_playing = true;
    playmode = playmode_arg;
    if (playmode == PlayMode.complete) {
        song_row_index = 0;
    }
    current_pos_in_pattern = 0;
}

pub fn stop() void {
    is_playing = false;
}

pub fn togglePlaying() void {
    is_playing = !is_playing;
}

pub fn getCurrentPatternPlayingPos() usize {
    return @intFromFloat(current_pos_in_pattern);
}

pub fn getCurrentSongRowIndex() usize {
    return song_row_index;
}

pub fn setCurrentSongRowIndex(song_row_index_arg: usize) void {
    song_row_index = song_row_index_arg;
    current_pos_in_pattern = 0;
}

const pos_delta = 0.00018;

fn generate() f32 {
    if (!is_playing) {
        return synth.generate();
    }

    const current_row_index = @floor(current_pos_in_pattern);
    if (@floor(current_pos_in_pattern - pos_delta) != current_row_index) {
        for (current_song.rows.items[song_row_index].cols, 0..) |pattern_id_opt, channel_index| {
            if (pattern_id_opt) |pattern_id| {
                const pattern = current_song.channels.items[channel_index].patterns.items[pattern_id];
                if (pattern.rows[@intFromFloat(current_row_index)].note) |note| {
                    synth.playNote(note, channel_index);
                }
            }
        }
    }

    current_pos_in_pattern += pos_delta;
    if (current_pos_in_pattern >= song_module.PATTEN_LENGTH) {
        if (playmode == PlayMode.complete) {
            song_row_index = (song_row_index + 1) % current_song.rows.items.len;
        }
        current_pos_in_pattern = current_pos_in_pattern - song_module.PATTEN_LENGTH;
    }

    return synth.generate();
}

pub fn audio_stream_callback(buffer: [*c]f32, num_frames: i32, num_channels: i32) callconv(.C) void {
    _ = num_channels;
    for (0..@intCast(num_frames)) |i| {
        const signal = generate() * 0.2;
        buffer[2 * i] = signal;
        buffer[2 * i + 1] = signal;
    }
}
