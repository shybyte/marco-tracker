const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const saudio = sokol.audio;
const sapp = sokol.app;
const sgapp = sokol.app_gfx_glue;

const keymap = @import("./keymap.zig");
const synth = @import("./synth/synth.zig");
const SAMPLE_RATE = @import("./constants.zig").SAMPLE_RATE;

const NumSamples = 32;

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
    var time: u32 = 0;
    var sample_pos: usize = 0;
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
        .sample_rate = SAMPLE_RATE,
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
        state.sample_pos += 1;
    }) {
        if (state.sample_pos == NumSamples) {
            state.sample_pos = 0;
            _ = saudio.push(&(state.samples[0]), NumSamples);
        }

        state.samples[state.sample_pos] = synth.generate();
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
        if (ev.key_code == sapp.Keycode.ESCAPE) {
            sapp.quit();
        }

        switch (ev.key_code) {
            .ESCAPE => {
                sapp.quit();
            },
            .F => {
                sapp.toggleFullscreen();
            },
            else => {
                if (keymap.get_note_for_key(ev.key_code)) |note| {
                    synth.playNote(note);
                }
            },
        }
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
        .window_title = "MarcoTracker",
        .logger = .{ .func = slog.func },
    });
}

// special entry point for Emscripten build, called from src/emscripten/entry.c
export fn emsc_main() void {
    main();
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
