const sokol = @import("sokol");
const sapp = sokol.app;
pub const FONT_SCALE_FACTOR = @import("../constants.zig").FONT_SCALE_FACTOR;

pub const Point2D = struct {
    x: f32 = 0,
    y: f32 = 0,
};

pub const Context = struct {
    mouse_pos: Point2D = .{},
    current_event: ?sapp.Event = null,
};

pub fn is_in_text_rect(mouse_pos: Point2D, text_rect_pos_chars: Point2D, text_length_chars: f32) bool {
    const font_size = 8 * FONT_SCALE_FACTOR;
    const text_rect_left_top = Point2D{ .x = text_rect_pos_chars.x * font_size, .y = text_rect_pos_chars.y * font_size };
    const text_rect_right_bottom = Point2D{ .x = text_rect_left_top.x + text_length_chars * font_size, .y = text_rect_left_top.y + font_size };
    return mouse_pos.x >= text_rect_left_top.x and mouse_pos.x < text_rect_right_bottom.x and
        mouse_pos.y >= text_rect_left_top.y and mouse_pos.y < text_rect_right_bottom.y;
}
