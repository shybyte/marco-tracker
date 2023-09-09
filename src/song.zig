const Note = @import("./notes.zig").Note;
const OscType = @import("./synth/osc.zig").OscType;

const PATTEN_LENGTH = 32;

pub const Pattern = struct { rows: [PATTEN_LENGTH]PatternRow };

pub const PatternRow = struct {
    note: ?Note = null,
};

pub const Song = struct {
    patterns: []Pattern,
    instruments: []Instrument,
};

pub const PATTERNS: [0]Pattern = [_]Pattern{};

pub const INSTRUMNETS: [0]Instrument = [_]Instrument{};

pub const EMPTY_SONG: Song = .{
    .patterns = &PATTERNS,
    .instruments = &INSTRUMNETS,
};

pub const Instrument = struct {
    osc_type: OscType = OscType.saw,
};
