const std = @import("std");
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const saudio = sokol.audio;
const sapp = sokol.app;
const sgapp = sokol.app_gfx_glue;
const sdtx = sokol.debugtext;

const keymap = @import("./keymap.zig");
const synth = @import("./synth/synth.zig");
const SYSTEM = @import("./songs/system.zig").SYSTEM;
const SAMPLE_RATE = @import("./constants.zig").SAMPLE_RATE;
const ui = @import("./ui/ui.zig");
const song_splayer = @import("./player.zig");
const storage = @import("./storage.zig");
const Song = @import("./song.zig").Song;
const midi = @import("./midi.zig");
const ENABLE_MIDI = @import("./constants.zig").ENABLE_MIDI;
const ENABLE_FILES = @import("./constants.zig").ENABLE_FILES;

const NumSamples = 32;

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
    var time: u32 = 0;
    var sample_pos: usize = 0;
    var samples: [NumSamples]f32 = undefined;
};

var pass_action: sg.PassAction = .{};

var parsed_song: ?std.json.Parsed(Song) = null;

// font indices
const C64 = 0;

export fn init() void {
    // slog.func("", 1, 2, "tet");
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
    };

    // setup sokol-debugtext with all builtin fonts
    var sdtx_desc: sdtx.Desc = .{ .logger = .{ .func = slog.func } };
    sdtx_desc.fonts[C64] = sdtx.fontC64();
    sdtx.setup(sdtx_desc);

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

    if (ENABLE_FILES) {
        const song_or_err = storage.loadSong(std.heap.page_allocator);
        if (song_or_err) |song| {
            parsed_song = song;
            song_splayer.setSong(song.value);
        } else |err| {
            std.log.debug("Error {}", .{err});
            song_splayer.setSong(SYSTEM);
        }
    } else {
        song_splayer.setSong(SYSTEM);
    }

    saudio.setup(.{
        .buffer_frames = 512,
        .num_channels = 2,
        .stream_cb = song_splayer.audio_stream_callback,
        .sample_rate = SAMPLE_RATE,
        .logger = .{ .func = slog.func },
    });

    if (ENABLE_MIDI) midi.init();
}

export fn frame() void {
    if (ENABLE_MIDI) {
        for (midi.readMidiEvents()) |midi_event| ui.onMidiInput(midi_event);
    }

    // default pass-action clears to grey
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());

    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);

    ui.draw();

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
            .F2 => {
                song_splayer.start();
            },
            .F4 => {
                song_splayer.stop();
            },
            .SPACE => {
                song_splayer.togglePlaying();
            },
            else => {
                if (ev.modifiers == sapp.modifier_alt) {
                    switch (ev.key_code) {
                        .W => {
                            if (ENABLE_FILES) {
                                storage.saveSong(song_splayer.getSong()) catch |err| {
                                    std.log.debug("Error {}", .{err});
                                };
                            }
                        },
                        else => {
                            ui.onInput(event);
                        },
                    }
                } else {
                    ui.onInput(event);
                }
            },
        }
    }
}

export fn cleanup() void {
    if (ENABLE_MIDI) midi.shutdown();
    saudio.shutdown();
    sg.shutdown();

    if (parsed_song) |song| song.deinit();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
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
