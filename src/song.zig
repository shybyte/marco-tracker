const Note = @import("./notes.zig").Note;

const PATTEN_LENGTH = 32;

pub const Pattern = struct { rows: [PATTEN_LENGTH]PatternRow };

pub const PatternRow = struct {
    note: ?Note = null,
};

pub const Song = struct {
    patterns: []Pattern,
};

pub const PATTERNS: [0]Pattern = [_]Pattern{};

pub const EMPTY_SONG: Song = .{
    .patterns = &PATTERNS,
};
