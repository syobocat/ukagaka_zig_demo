const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

const ukadll = @import("ukadll");

const core = @import("core");
const Ghost = core.Ghost;

const root_allocator = std.heap.c_allocator;

var io_threaded: Io.Threaded = undefined;
var ghost: Ghost = undefined;

export const loadu = ukadll.load(_loadu);
export const unload = ukadll.unload(_unload);
export const request = ukadll.request(root_allocator, _request);

fn _loadu(_: []const u8) !void {
    io_threaded = .init(root_allocator, .{});
    ghost = try .init(io_threaded.io(), root_allocator);
}

fn _unload() void {
    io_threaded.deinit();
}

fn _request(arena: Allocator, body: []const u8) [:0]const u8 {
    const resp = ghost.handleRequest(arena, body);
    return resp.render(arena);
}
