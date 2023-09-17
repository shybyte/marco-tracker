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

pub fn draw(ui_context: UiContext, inst: *Instrument, screen_pos: Point2D) void {
    sdtx.canvas(sapp.widthf() / FONT_SCALE_FACTOR, sapp.heightf() / FONT_SCALE_FACTOR);
    var text_pos: Point2D = screen_pos;
    sdtx.origin(text_pos.x, text_pos.y);
    sdtx.home();

    {
        const is_under_mouse = is_in_text_rect(ui_context.mouse_pos, text_pos, 12);
        if (is_under_mouse) {
            sdtx.color3f(1, 0.3, 1);
            if (ui_context.current_event) |ev| {
                if (ev.type == .MOUSE_SCROLL) {
                    const enum__nember_count = @intFromEnum(OscType.triangle) + 1;
                    if (ev.scroll_y < 0) {
                        inst.osc_type = @enumFromInt((@intFromEnum(inst.osc_type) + enum__nember_count - 1) % enum__nember_count);
                    } else {
                        inst.osc_type = @enumFromInt((@intFromEnum(inst.osc_type) + 1) % enum__nember_count);
                    }
                }
            }
        } else {
            sdtx.color3f(0.3, 0.3, 0.5);
        }
        sdtx.print("OscType: {s}", .{@tagName(inst.osc_type)});
    }

    sdtx.sdtx_crlf();
    text_pos.y += 1;

    inst.adsr_attack = number_input(inst.adsr_attack, "Attack", text_pos, ui_context);

    sdtx.sdtx_crlf();
    text_pos.y += 1;

    inst.adsr_release = number_input(inst.adsr_release, "Release", text_pos, ui_context);

    synth.setInstrument(inst);
}

fn number_input(value: f32, label: []const u8, current_char_pos: Point2D, ui_context: UiContext) f32 {
    var result: f32 = value;
    const is_under_mouse = is_in_text_rect(ui_context.mouse_pos, current_char_pos, 12);
    if (is_under_mouse) {
        sdtx.color3f(1, 0.3, 1);
        if (ui_context.current_event) |ev| {
            if (ev.type == .MOUSE_SCROLL) {
                result = keep_in_range(value + ev.scroll_y * 0.1, 0, 5);
            }
        }
    } else {
        sdtx.color3f(0.3, 0.3, 0.5);
    }
    sdtx.print("{s}: {d:.4}", .{ label, value });
    return result;
}

fn keep_in_range(x: f32, min: f32, max: f32) f32 {
    return @min(@max(x, min), max);
}

fn is_in_text_rect(mouse_pos: Point2D, text_rect_pos_chars: Point2D, text_length_chars: f32) bool {
    const font_size = 8 * FONT_SCALE_FACTOR;
    const text_rect_left_top = Point2D{ .x = text_rect_pos_chars.x * font_size, .y = text_rect_pos_chars.y * font_size };
    const text_rect_right_bottom = Point2D{ .x = text_rect_left_top.x + text_length_chars * font_size, .y = text_rect_left_top.y + font_size };
    return mouse_pos.x >= text_rect_left_top.x and mouse_pos.x < text_rect_right_bottom.x and
        mouse_pos.y >= text_rect_left_top.y and mouse_pos.y < text_rect_right_bottom.y;
}
