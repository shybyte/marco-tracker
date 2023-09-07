const std = @import("std");
const song_module = @import("./song.zig");
const Song = song_module.Song;

const FILE_NAME = "songs/system.json";

pub fn loadSong(allocator: std.mem.Allocator) !std.json.Parsed(Song) {
    const json_string = try std.fs.cwd().readFileAlloc(allocator, FILE_NAME, 1024 * 1024);
    defer allocator.free(json_string);

    const loaded_song = try std.json.parseFromSlice(Song, allocator, json_string, .{});
    return loaded_song;
}

pub fn saveSong(song: *Song) !void {
    var string_buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer string_buffer.deinit();

    try std.json.stringify(song, .{ .whitespace = .indent_2 }, string_buffer.writer());
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
    const parsed_song = try loadSong(std.testing.allocator);
    defer parsed_song.deinit();

    try std.testing.expect(parsed_song.value.patterns.len == 1);
}
