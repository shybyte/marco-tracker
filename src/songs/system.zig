const song = @import("../song.zig");
const n = @import("../notes.zig");

pub const SYSTEM_PATTERN: song.Pattern = song.Pattern{
    .rows = [_]song.PatternRow{
        .{ .note = n.A3 },
        .{},
        .{ .note = n.A4 },
        .{ .note = n.C5 },

        .{ .note = n.A3 },
        .{},
        .{ .note = n.A4 },
        .{ .note = n.C5 },

        .{ .note = n.F3 },
        .{},
        .{ .note = n.F4 },
        .{ .note = n.C5 },

        .{ .note = n.F3 },
        .{ .note = n.F4 },
        .{ .note = n.C5 },
        .{},

        .{ .note = n.D4 },
        .{},
        .{ .note = n.D5 },
        .{ .note = n.D6 },

        .{ .note = n.D4 },
        .{ .note = n.D5 },
        .{ .note = n.F5 },
        .{},

        .{ .note = n.D4 },
        .{},
        .{ .note = n.Cis5 },
        .{ .note = n.D5 },

        .{},
        .{},
        .{ .note = n.F5 },
        .{ .note = n.A5 },
    },
};
