const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const Io = std.Io;
const ZonDiag = std.zon.parse.Diagnostics;

affection: u32 = 0,

pub fn load(io: Io, allocator: Allocator) @This() {
    const cwd = Io.Dir.cwd();
    const content = cwd.readFileAllocOptions(io, "data.zon", allocator, .unlimited, .@"8", 0) catch return .{};
    defer allocator.free(content);

    var arena: ArenaAllocator = .init(allocator);
    defer arena.deinit();
    const parsed = std.zon.parse.fromSliceNoAlloc(@This(), .{
        .gpa = allocator,
        .arena = arena.allocator(),
        .source = content,
        .diagnostics = undefined,
    }) catch return .{};

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
