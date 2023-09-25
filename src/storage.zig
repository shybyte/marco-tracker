const std = @import("std");
const song_module = @import("./song.zig");

const FILE_NAME = "songs/system.json";

const Note = @import("./notes.zig").Note;
const OscType = @import("./synth/osc.zig").OscType;

pub const Channel = struct {
    patterns: []song_module.Pattern,
};

pub const Song = struct {
    rows: []song_module.SongRow,
    channels: []Channel,
    instruments: []song_module.Instrument,
};

pub const PatternID = ?usize;

pub fn loadSong(allocator: std.mem.Allocator) !song_module.Song {
    const json_string = try std.fs.cwd().readFileAlloc(allocator, FILE_NAME, 1024 * 1024);
    defer allocator.free(json_string);

    const parsed_song = try std.json.parseFromSlice(Song, allocator, json_string, .{});
    defer parsed_song.deinit();

    var loaded_song: song_module.Song = song_module.Song{
        .rows = std.ArrayList(song_module.SongRow).init(allocator),
        .channels = std.ArrayList(song_module.Channel).init(allocator),
        .instruments = std.ArrayList(song_module.Instrument).init(allocator),
    };

    for (parsed_song.value.rows) |row| {
        try loaded_song.rows.append(row);
    }

    for (parsed_song.value.channels) |parsed_channel| {
        var channel: song_module.Channel = .{ .patterns = std.ArrayList(song_module.Pattern).init(allocator) };
        for (parsed_channel.patterns) |pattern| {
            try channel.patterns.append(pattern);
        }
        try loaded_song.channels.append(channel);
    }

    for (parsed_song.value.instruments) |inst| {
        try loaded_song.instruments.append(inst);
    }

    return loaded_song;
}

pub fn saveSong(song: *const song_module.Song, allocator: std.mem.Allocator) !void {
    var string_buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer string_buffer.deinit();

    var channels = std.ArrayList(Channel).init(allocator);

    for (song.channels.items) |channel| {
        try channels.append(.{ .patterns = channel.patterns.items });
    }

    const json_song: Song = .{
        .rows = song.rows.items,
        .channels = channels.items,
        .instruments = song.instruments.items,
    };

    try std.json.stringify(json_song, .{ .whitespace = .indent_2 }, string_buffer.writer());
    const json_string = try string_buffer.toOwnedSlice();
    std.log.debug("json {s}", .{json_string});

    const file = try std.fs.cwd().createFile(
        FILE_NAME,
        .{},
    );
    defer file.close();

    try file.writeAll(json_string);
}

test "loadSong" {
    const song = try loadSong(std.testing.allocator);
    defer song.deinit();

    try std.testing.expect(song.channels.items.len == 4);
}
