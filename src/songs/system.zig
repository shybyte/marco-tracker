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

var PATTERNS = [_]song.Pattern{SYSTEM_PATTERN};

pub const SYSTEM: song.Song = .{
    .patterns = &PATTERNS,
};
