const std = @import("std");
const Io = std.Io;
const Rng = std.Random.DefaultPrng;

rng: Rng,
timer: u16,

pub fn init(io: Io) !@This() {
    // Initialize RNG
    var seed: u64 = undefined;
    io.random(std.mem.asBytes(&seed));
    const rng: Rng = .init(seed);

    var self: @This() = .{
        .rng = rng,
        .timer = undefined,
    };

    // Initialize timer
    self.resetTimer();

    return self;
}

pub fn resetTimer(self: *@This()) void {
    const random = self.rng.random();
    self.timer = random.intRangeAtMost(u16, 120, 180);
}
