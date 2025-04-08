const std = @import("std");
const json = std.json;
const mem = std.mem;
const Build = std.Build;
const Step = Build.Step;
const Compile = Step.Compile;
const fs = std.fs;

const CompileCommands = @import("compile_commands");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const flags: []const []const u8 = &.{
        "-std=c23",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-Wpedantic",
        "-fno-strict-aliasing",
        "-gen-cdb-fragment-path",
        b.fmt("{s}/{s}", .{ b.cache_root.path.?, "cdb" }),
    };

    // Modules
    const bintools_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = true,
    });
    const pelf_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = true,
    });

    bintools_mod.addIncludePath(b.path("include"));
    bintools_mod.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"bintools/elf.c"},
        .flags = flags,
    });

    pelf_mod.addIncludePath(b.path("include"));
    pelf_mod.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"pelf.c"},
        .flags = flags,
    });

    // Targets
    const bintools = b.addLibrary(.{
        .name = "bintools",
        .root_module = bintools_mod,
    });
    const pelf = b.addExecutable(.{
        .name = "pelf",
        .root_module = pelf_mod,
    });

    // Install
    // bintools.installHeader(b.path("include/bintools.h"), "include");
    bintools.installHeadersDirectory(b.path("include/bintools"), "bintools", .{});
    b.installArtifact(bintools);
    b.installArtifact(pelf);
    pelf.linkLibrary(bintools);

    // Run
    const run_cmd = b.addRunArtifact(pelf);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // gen compile_commands.json
    const cc_step = b.step("cc", "Generate Compile Commands Database");
    const gen_file_step = try CompileCommands.createStep(
        b,
        b.fmt("{s}/{s}", .{ b.cache_root.path orelse "./", "cdb" }),
        b.fmt("{s}/{s}", .{ b.cache_root.path orelse "./", "compile_commands.json" }),
    );
    gen_file_step.dependOn(&bintools.step);
    gen_file_step.dependOn(&pelf.step);
    cc_step.dependOn(gen_file_step);

    // clean up
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&b.addRemoveDirTree(b.path(fs.path.basename(b.install_path))).step);
    clean_step.dependOn(&b.addRemoveDirTree(b.path(".zig-cache")).step);
}
