const Builder = @import("std").build.Builder;

fn buildTutorialExe(name: []const u8, src: []const u8, description: []const u8, b: *Builder) void {
    const exe = b.addExecutable(name, src);
    exe.setBuildMode(b.standardReleaseOptions());

    // Link with system libraries needed for OpenGL.
    exe.linkLibC();
    exe.linkSystemLibrary("glfw");
    exe.linkSystemLibrary("epoxy");

    b.default_step.dependOn(&exe.step);
    b.step(name, description).dependOn(&exe.run().step);
}

pub fn build(b: *Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    buildTutorialExe("window", "src/window.zig", "Show a simple GLFW window", b);
    buildTutorialExe("triangle", "src/triangle.zig", "Draw a triangle with OpenGL", b);
}
