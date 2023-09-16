const sokol = @import("sokol");
const sapp = sokol.app;

pub const Point2D = struct {
    x: f32 = 0,
    y: f32 = 0,
};

pub const Context = struct {
    mouse_pos: Point2D = .{},
    current_event: ?sapp.Event = null,
};
