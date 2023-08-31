const song_player = @import("../player.zig");
const draw_pattern = @import("./pattern.zig").drawPattern;

pub fn draw() void {
    draw_pattern(song_player.getCurrentPattern());
}
