const song = @import("../song.zig");
const n = @import("../notes.zig");

pub const SYSTEM_PATTERN: song.Pattern = song.Pattern{
    .rows = [_]song.PatternRow{
        .{ .note = n.A2 },
        .{},
        .{ .note = n.A3 },
        .{ .note = n.C4 },

        .{ .note = n.A2 },
        .{},
        .{ .note = n.A3 },
        .{ .note = n.C4 },

        .{ .note = n.F2 },
        .{},
        .{ .note = n.F3 },
        .{ .note = n.C4 },

        .{ .note = n.F2 },
        .{ .note = n.F3 },
        .{ .note = n.C4 },
        .{},

        .{ .note = n.D3 },
        .{},
        .{ .note = n.D4 },
        .{ .note = n.D5 },

        .{ .note = n.D3 },
        .{ .note = n.D4 },
        .{ .note = n.F4 },
        .{},

        .{ .note = n.D3 },
        .{},
        .{ .note = n.Cis4 },
        .{ .note = n.D4 },

        .{},
        .{},
        .{ .note = n.F4 },
        .{ .note = n.A4 },
    },
};

pub const SYSTEM_PATTERN_STRINGS: song.Pattern = song.Pattern{
    .rows = [_]song.PatternRow{
        .{ .note = n.A4 },
        .{},
        .{},
        .{},

        .{},
        .{},

        .{ .note = n.D4 },
        .{ .note = n.E4 },

        .{ .note = n.F4 },
        .{},
        .{},
        .{},

        .{ .note = n.E4 },
        .{},
        .{ .note = n.F4 },
        .{},

        .{ .note = n.D4 },
        .{},
        .{},
        .{},

        .{},
        .{},
        .{},
        .{},

        .{},
        .{},
        .{},
        .{},

        .{},
        .{},
        .{},
        .{},
    },
};

pub const EMPTY_PATTERN: song.Pattern = song.Pattern{ .rows = [_]song.PatternRow{.{ .note = null }} ** 32 };

var PATTERNS_0 = [_]song.Pattern{SYSTEM_PATTERN};
var PATTERNS_1 = [_]song.Pattern{SYSTEM_PATTERN_STRINGS};
var EMPTY_PATTERNS = [_]song.Pattern{EMPTY_PATTERN};
var CHANNELS = [_]song.Channel{
    .{ .patterns = &PATTERNS_0 },
    .{ .patterns = &PATTERNS_1 },
    .{ .patterns = &EMPTY_PATTERNS },
    .{ .patterns = &EMPTY_PATTERNS },
};

const SIMPLE_INST: song.Instrument = .{
    .osc_type = .saw,
};

const SIMPLE_INST_SINE: song.Instrument = .{
    .osc_type = .sin,
};

var INSTRUMENTS = [_]song.Instrument{ SIMPLE_INST, SIMPLE_INST_SINE };

var SONG_ROWS = [_]song.SongRow{.{ .cols = [4]song.PatternID{ 0, 0, null, null } }};

pub const SYSTEM: song.Song = .{ .channels = &CHANNELS, .instruments = &INSTRUMENTS, .rows = &SONG_ROWS };
