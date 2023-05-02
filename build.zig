const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const native_target = (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target;

    const lib = b.addStaticLibrary(.{ .name = "flac", .target = target, .optimize = optimize });
    lib.linkLibC();
    lib.addIncludePath("include");
    lib.addIncludePath("src/libFLAC/include");
    lib.addCSourceFiles(&sources, &.{"-DHAVE_CONFIG_H"});
    const config_header = b.addConfigHeader(
        .{ .style = .blank },
        .{
            .ENABLE_64_BIT_WORDS = native_target.cpu.arch.ptrBitWidth() == 64,
            .CPU_IS_BIG_ENDIAN = native_target.cpu.arch.endian() == .Big,
            .HAVE_BSWAP16 = 1,
            .HAVE_BSWAP32 = 1,
            .HAVE_INTTYPES_H = 1,
            .HAVE_LROUND = 1,
            .FLAC__CPU_ARM64 = native_target.cpu.arch.isAARCH64(),
            .FLAC__SSE2_SUPPORTED = native_target.cpu.arch.isX86(),
            .FLAC__HAS_X86INTRIN = 1,
            .FLAC__SYS_DARWIN = native_target.os.tag.isDarwin(),
            .FLAC__SYS_LINUX = native_target.os.tag == .linux,
            .FLAC__HAS_OGG = 0,
            .PACKAGE_VERSION = "1.4.2",
        },
    );
    lib.addConfigHeader(config_header);
    b.installArtifact(lib);
}

const sources = [_][]const u8{
    "src/libFLAC/bitmath.c",
    "src/libFLAC/bitreader.c",
    "src/libFLAC/bitwriter.c",
    "src/libFLAC/cpu.c",
    "src/libFLAC/crc.c",
    "src/libFLAC/fixed.c",
    "src/libFLAC/fixed_intrin_sse2.c",
    "src/libFLAC/fixed_intrin_ssse3.c",
    "src/libFLAC/fixed_intrin_sse42.c",
    "src/libFLAC/fixed_intrin_avx2.c",
    "src/libFLAC/float.c",
    "src/libFLAC/format.c",
    "src/libFLAC/lpc.c",
    "src/libFLAC/lpc_intrin_neon.c",
    "src/libFLAC/lpc_intrin_sse2.c",
    "src/libFLAC/lpc_intrin_sse41.c",
    "src/libFLAC/lpc_intrin_avx2.c",
    "src/libFLAC/lpc_intrin_fma.c",
    "src/libFLAC/md5.c",
    "src/libFLAC/memory.c",
    "src/libFLAC/metadata_iterators.c",
    "src/libFLAC/metadata_object.c",
    "src/libFLAC/stream_decoder.c",
    "src/libFLAC/stream_encoder.c",
    "src/libFLAC/stream_encoder_intrin_sse2.c",
    "src/libFLAC/stream_encoder_intrin_ssse3.c",
    "src/libFLAC/stream_encoder_intrin_avx2.c",
    "src/libFLAC/stream_encoder_framing.c",
    "src/libFLAC/window.c",
};
