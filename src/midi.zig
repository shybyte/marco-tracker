const std = @import("std");
const portmidi = @import("./portmidi/portmidi.zig");
const Note = @import("./notes.zig").Note;

var midi_in_stream: ?*portmidi.Stream = undefined;

pub const MidiEvent = struct {
    message: u32,

    const Self = @This();

    pub fn getNoteOn(self: Self) ?Note {
        const status = portmidi.messageStatus(self.message);
        // std.log.debug("Status {}", .{status});
        const command = status & 0xf0;
        if (command == portmidi.midi.note_on and portmidi.messageData2(self.message) > 0) {
            return portmidi.messageData1(self.message);
        } else {
            return null;
        }
    }
};

pub fn init() void {
    portmidi.initialize();
    const device_count = portmidi.countDevices();
    std.log.debug("DeviceCount {}", .{device_count});
    for (0..(@intCast(device_count))) |i| {
        const device_info = portmidi.getDeviceInfo(@intCast(i)).?;
        std.log.debug("Midi Device {d} Name='{s}' Input={} Output={} {}", .{ i, device_info.name, device_info.input, device_info.output, device_info });
    }

    portmidi.openInput(&midi_in_stream, 3, null, 512, null, null) catch |err| {
        std.log.err("Ppen MidiStream error {}", .{err});
    };
}

var portmidi_in_events: [32]portmidi.Event = [_]portmidi.Event{.{ .message = 0, .timestamp = 0 }} ** 32;
var midi_in_events: [32]MidiEvent = [_]MidiEvent{.{ .message = 0 }} ** 32;

pub fn readMidiEvents() []const MidiEvent {
    const midi_event_count = portmidi.read(midi_in_stream, &portmidi_in_events[0], portmidi_in_events.len) catch |err| blk: {
        std.log.err("Read MidiStream error {}", .{err});
        break :blk 0;
    };

    for (portmidi_in_events[0..@intCast(midi_event_count)], midi_in_events[0..@intCast(midi_event_count)]) |portmidi_event, *midi_event| {
        // std.log.debug("MidiEvent {}", .{portmidi_event});
        midi_event.message = portmidi_event.message;
    }

    return midi_in_events[0..@intCast(midi_event_count)];
}

pub fn shutdown() void {
    portmidi.close(midi_in_stream) catch |err| {
        std.log.err("Close MidiStream error {}", .{err});
    };

    portmidi.terminate();
}
