const std = @import("std");
const Note = @import("./notes.zig").Note;
const OscType = @import("./synth/osc.zig").OscType;

pub const CHANNEL_NUM = 4;

pub const PATTEN_LENGTH = 32;

pub const Pattern = struct { rows: [PATTEN_LENGTH]PatternRow };

pub const PatternRow = struct {
    note: ?Note = null,
};

pub const Channel = struct {
    patterns: std.ArrayList(Pattern),

    const Self = @This();

    pub fn ensurePattern(self: *Self, patternIndex: usize) !*Pattern {
        if (patternIndex >= self.patterns.items.len) {
            try self.patterns.resize(patternIndex + 1);
            self.patterns.items[patternIndex] = EMTPY_PATTERN;
        }
        return &self.patterns.items[patternIndex];
    }
};

pub const Song = struct {
    rows: std.ArrayList(SongRow),
    channels: std.ArrayList(Channel),
    instruments: std.ArrayList(Instrument),

    const Self = @This();

    pub fn deinit(self: Self) void {
        self.rows.deinit();

        for (self.channels.items) |channel| {
            channel.patterns.deinit();
        }
        self.channels.deinit();

        self.instruments.deinit();
    }
};

pub const PatternID = ?usize;

pub const SongRow = struct {
    cols: [CHANNEL_NUM]PatternID,
};

pub const Instrument = struct {
    osc_type: OscType = OscType.saw,
    adsr_attack: f32 = 0.01,
    adsr_release: f32 = 0.5,
};

pub const EMTPY_PATTERN: Pattern = .{ .rows = [_]PatternRow{.{ .note = null }} ** PATTEN_LENGTH };
const PATTERNS: [0]Pattern = [_]Pattern{};
const INSTRUMNETS: [0]Instrument = [_]Instrument{};
const SONG_ROWS = [_]SongRow{.{ .cols = [4]PatternID{ 0, null, null, null } }};

pub fn createEmptySong() !Song {
    const allocator = std.heap.page_allocator;
    return Song{
        .rows = std.ArrayList(SongRow).init(allocator),
        .channels = std.ArrayList(Channel).init(allocator),
        .instruments = std.ArrayList(Instrument).init(allocator),
    };
}
