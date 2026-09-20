const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const StaticStringMap = std.StaticStringMap;

const shiori = @import("shiori");
const References = shiori.References;
const Request = shiori.Request;
const Response = shiori.Response;

const build_info = @import("build_info");

const State = @import("State.zig");
const Save = @import("Save.zig");

const talks = @import("talks.zig");

io: Io,
allocator: Allocator,

state: State,
save: Save,

pub fn init(io: Io, allocator: Allocator) !@This() {
    return .{
        .io = io,
        .allocator = allocator,
        .state = try .init(io),
        .save = .load(io, allocator),
    };
}

fn randomTalk(ghost: *@This()) []const u8 {
    const random = ghost.state.rng.random();
    if (ghost.save.affection < 100) {
        const talk_count = talks.normal_talks.len;
        const idx = random.uintLessThan(usize, talk_count);
        return talks.normal_talks[idx];
    } else {
        const talk_count = talks.normal_talks.len + talks.special_talks.len;
        const combined_idx = random.uintLessThan(usize, talk_count);
        if (combined_idx >= talks.normal_talks.len) {
            const idx = combined_idx - talks.normal_talks.len;
            return talks.special_talks[idx];
        } else {
            return talks.normal_talks[combined_idx];
        }
    }
}

const handlers: StaticStringMap(*const fn (*@This(), Allocator, References) anyerror!Response) = .initComptime(.{
    // SHIORI Resource
    .{ "version", &version },
    .{ "craftman", &craftman },
    .{ "craftmanw", &craftman },
    .{ "name", &name },

    // SHIORI Event
    .{ "OnBoot", &onBoot },
    .{ "OnAITalk", &onAiTalk },
    .{ "OnMouseDoubleClick", &onAiTalk },
    .{ "OnSecondChange", &onSecondChange },
});

pub fn handleRequest(self: *@This(), allocator: Allocator, body: []const u8) Response {
    const req = Request.parse(allocator, body) catch {
        return .{ .status = .bad_request };
    };

    if (req.method == .notify) {
        return .{};
    }

    const handler = handlers.get(req.id) orelse {
        return .{};
    };

    const resp = handler(self, allocator, req.references) catch {
        return .{ .status = .internal_server_error };
    };

    return resp;
}

fn version(_: *@This(), _: Allocator, _: References) !Response {
    return .{
        .status = .ok,
        .value = build_info.version,
    };
}

fn craftman(_: *@This(), _: Allocator, _: References) !Response {
    return .{
        .status = .ok,
        .value = "SyoBoN",
    };
}

fn name(_: *@This(), _: Allocator, _: References) !Response {
    return .{
        .status = .ok,
        .value = "zSHIORI",
    };
}

fn onBoot(_: *@This(), _: Allocator, _: References) !Response {
    return .{
        .status = .ok,
        .value =
        \\\s0こんにちは。\e
        ,
    };
}

fn onAiTalk(ghost: *@This(), _: Allocator, _: References) !Response {
    const talk = ghost.randomTalk();

    return .{
        .status = .ok,
        .value = talk,
    };
}

fn onSecondChange(ghost: *@This(), _: Allocator, _: References) !Response {
    ghost.state.timer -= 1;

    const random = ghost.state.rng.random();
    if (random.float(f32) < 0.01) {
        ghost.save.affection +|= 1;
        try ghost.save.save(ghost.io);
    }

    if (ghost.state.timer == 0) {
        ghost.state.resetTimer();
        const talk = ghost.randomTalk();

        return .{
            .status = .ok,
            .value = talk,
        };
    }

    return .{};
}
