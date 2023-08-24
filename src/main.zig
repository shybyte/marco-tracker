const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const saudio = sokol.audio;
const sapp = sokol.app;
const sgapp = sokol.app_gfx_glue;

const NumSamples = 32;

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
    var even_odd: u32 = 0;
    var sample_pos: usize = 0;
    var sound_volume: f32 = 0.1;
    var samples: [NumSamples]f32 = undefined;
};

export fn init() void {
    // slog.func("", 1, 2, "tet");
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    saudio.setup(.{
        .buffer_frames = 256,
        .logger = .{ .func = slog.func },
    });

    // create vertex buffer with triangle vertices
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions         colors
            0.0,  0.5,  0.5, 1.0, 0.0, 0.0, 1.0,
            0.5,  -0.5, 0.5, 0.0, 1.0, 0.0, 1.0,
            -0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0,
        }),
    });

    // create a shader and pipeline object
    const shd = sg.makeShader(shaderDesc());
    var pip_desc: sg.PipelineDesc = .{ .shader = shd };
    pip_desc.layout.attrs[0].format = .FLOAT3;
    pip_desc.layout.attrs[1].format = .FLOAT4;
    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    const num_frames = saudio.expect();
    var i: i32 = 0;
    while (i < num_frames) : ({
        i += 1;
        state.even_odd += 1;
        state.sample_pos += 1;
    }) {
        if (state.sample_pos == NumSamples) {
            state.sample_pos = 0;
            _ = saudio.push(&(state.samples[0]), NumSamples);
        }
        state.samples[state.sample_pos] = if (0 != (state.even_odd & 0x20)) state.sound_volume else -state.sound_volume;
    }

    // default pass-action clears to grey
    sg.beginDefaultPass(.{}, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);
    sg.endPass();
    sg.commit();
}

export fn input(event: ?*const sapp.Event) void {
    const ev = event.?;
    if (ev.type == .KEY_DOWN) {
        state.sound_volume = switch (ev.key_code) {
            ._1 => 0.0,
            ._2 => 0.1,
            ._3 => 0.5,
            else => 0.1,
        };
    }
}

export fn cleanup() void {
    saudio.shutdown();
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "triangle.zig",
        .logger = .{ .func = slog.func },
    });
}

// special entry point for Emscripten build, called from src/emscripten/entry.c
export fn emsc_main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "triangle.zig",
        .logger = .{ .func = slog.func },
    });
}

fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.attrs[0].name = "position";
    desc.attrs[1].name = "color0";
    desc.vs.source =
        \\ #version 300 es
        \\ precision mediump float;
        \\ in vec4 position;
        \\ in vec4 color0;
        \\ out vec4 color;
        \\ void main() {
        \\   gl_Position = position;
        \\   color = color0;
        \\ }
    ;
    desc.fs.source =
        \\ #version 300 es
        \\ precision mediump float;
        \\ in vec4 color;
        \\ out vec4 frag_color;
        \\ void main() {
        \\   frag_color = color;
        \\ }
    ;
    return desc;
}
