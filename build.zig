const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    // Build core
    const shiori = b.dependency("shiori", .{});

    const build_info = @import("build.zig.zon");
    const build_options = b.addOptions();
    build_options.addOption([]const u8, "version", build_info.version);

    const core = b.createModule(.{
        .root_source_file = b.path("src/core/root.zig"),
        .imports = &.{
            .{ .name = "shiori", .module = shiori.module("shiori") },
            .{ .name = "build_info", .module = build_options.createModule() },
        },
    });

    // Build .dll / .dylib
    const target_win = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .windows,
    });
    const target_mac = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    });
    inline for (.{ target_win, target_mac }) |target| {
        const ukadll = b.dependency("ukadll", .{
            .target = target,
        });

        const lib = b.addLibrary(.{
            .linkage = .dynamic,
            .name = "shiori",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/root.zig"),
                .target = target,
                .optimize = optimize,
                .link_libc = true,
                .imports = &.{
                    .{ .name = "ukadll", .module = ukadll.module("ukadll") },
                    .{ .name = "core", .module = core },
                },
            }),
        });

        const install = b.addInstallArtifact(lib, .{
            .dest_dir = .{ .override = .{ .custom = "../public/ghost/master/" } },
            .implib_dir = .disabled,
            .pdb_dir = .disabled,
        });

        b.default_step.dependOn(&install.step);
    }
}
