const Note = @import("./notes.zig").Note;
const OscType = @import("./synth/osc.zig").OscType;

pub const CHANNEL_NUM = 4;

pub const PATTEN_LENGTH = 32;

pub const Pattern = struct { rows: [PATTEN_LENGTH]PatternRow };

pub const PatternRow = struct {
    note: ?Note = null,
};

pub const Channel = struct {
    patterns: []Pattern,
};

pub const Song = struct {
    rows: []SongRow,
    channels: []Channel,
    instruments: []Instrument,
};

pub const PatternID = ?usize;

pub const SongRow = struct {
    cols: [CHANNEL_NUM]PatternID,
};

pub const PATTERNS: [0]Pattern = [_]Pattern{};

pub const INSTRUMNETS: [0]Instrument = [_]Instrument{};

var SONG_ROWS = [_]SongRow{.{ .cols = [4]PatternID{ 0, null, null, null } }};
var CHANNELS = [_]Channel{
    .{ .patterns = &PATTERNS },
    .{ .patterns = &PATTERNS },
    .{ .patterns = &PATTERNS },
    .{ .patterns = &PATTERNS },
};

pub const EMPTY_SONG: Song = .{
    .rows = &SONG_ROWS,
    .channels = &CHANNELS,
    .instruments = &INSTRUMNETS,
};

pub const Instrument = struct {
    osc_type: OscType = OscType.saw,
    adsr_attack: f32 = 0.01,
    adsr_release: f32 = 0.5,
};
