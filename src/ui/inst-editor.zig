const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sdtx = sokol.debugtext;
const Instrument = @import("../song.zig").Instrument;
const song_player = @import("../player.zig");
const Point2D = @import("./utils.zig").Point2D;
const UiContext = @import("./utils.zig").Context;
const OscType = @import("../synth/osc.zig").OscType;
const synth = @import("../synth/synth.zig");

const FONT_SCALE_FACTOR = 2;

pub fn draw(ui_context: UiContext, inst: Instrument) void {
    sdtx.canvas(sapp.widthf() / FONT_SCALE_FACTOR, sapp.heightf() / FONT_SCALE_FACTOR);
    sdtx.origin(20, 0);

    sdtx.home();
    const is_under_mouse = is_in_text_rect(ui_context.mouse_pos, .{ .x = 20, .y = 0 }, 12);
    if (is_under_mouse) {
        sdtx.color3f(1, 0.3, 1);
    } else {
        sdtx.color3f(0.3, 0.3, 0.5);
    }
    sdtx.print("OscType: {s}", .{@tagName(inst.osc_type)});
}

pub fn onInput(ui_context: UiContext, event: ?*const sapp.Event) void {
    const ev = event.?;
    // std.log.info("modifiers: {}", .{ev.modifiers});
    if (ev.type == .MOUSE_SCROLL and is_in_text_rect(ui_context.mouse_pos, .{ .x = 20, .y = 0 }, 12)) {
        std.log.info("inst-editor MouseScroll: {d}", .{ev.scroll_y});
        var inst = &song_player.getSong().instruments[0];
        const enum__nember_count = @intFromEnum(OscType.triangle) + 1;
        if (ev.scroll_y < 0) {
            inst.osc_type = @enumFromInt((@intFromEnum(inst.osc_type) + enum__nember_count - 1) % enum__nember_count);
        } else {
            inst.osc_type = @enumFromInt((@intFromEnum(inst.osc_type) + 1) % enum__nember_count);
        }
        synth.setInstrument(inst);
    }
}

fn is_in_text_rect(mouse_pos: Point2D, text_rect_pos_chars: Point2D, text_length_chars: f32) bool {
    const font_size = 8 * FONT_SCALE_FACTOR;
    const text_rect_left_top = Point2D{ .x = text_rect_pos_chars.x * font_size, .y = text_rect_pos_chars.y * font_size };
    const text_rect_right_bottom = Point2D{ .x = text_rect_left_top.x + text_length_chars * font_size, .y = text_rect_left_top.y + font_size };
    return mouse_pos.x >= text_rect_left_top.x and mouse_pos.x < text_rect_right_bottom.x and
        mouse_pos.y >= text_rect_left_top.y and mouse_pos.y < text_rect_right_bottom.y;
}
