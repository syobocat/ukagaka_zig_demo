const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

affection: u32 = 0,

pub fn load(io: Io, allocator: Allocator) @This() {
    const cwd = Io.Dir.cwd();
    const content = cwd.readFileAllocOptions(io, "data.zon", allocator, .unlimited, .@"8", 0) catch return .{};
    defer allocator.free(content);

    const parsed = std.zon.parse.fromSlice(@This(), allocator, content, null, .{}) catch return .{};

    return parsed;
}

pub fn save(self: @This(), io: Io) !void {
    const cwd = Io.Dir.cwd();
    var atomic = try cwd.createFileAtomic(io, "data.zon", .{ .replace = true });
    defer atomic.deinit(io);

    var buffer: [4096]u8 = undefined;
    var writer = atomic.file.writer(io, &buffer);
    try std.zon.stringify.serialize(self, .{ .whitespace = false }, &writer.interface);
    try writer.end();
    try atomic.replace(io);
}
