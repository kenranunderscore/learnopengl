const c = @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});
const std = @import("std");

/// Any of the three shader kinds.
pub const ShaderKind = enum {
    vertex,
    fragment,
    geometry,
};

/// Convert from `ShaderKind` to its corresponding `GLenum` value.
fn toGLenum(shader_kind: ShaderKind) c.GLenum {
    return switch (shader_kind) {
        ShaderKind.vertex => c.GL_VERTEX_SHADER,
        ShaderKind.fragment => c.GL_FRAGMENT_SHADER,
        ShaderKind.geometry => c.GL_GEOMETRY_SHADER,
    };
}

/// Try to load and compile a shader, given some source code and
/// the shader kind.
fn loadShader(code: []const u8, kind: ShaderKind) !c.GLuint {
    const id = c.glCreateShader(toGLenum(kind));
    const code_size = @intCast(c.GLint, code.len);
    c.glShaderSource(id, 1, &code.ptr, &code_size);
    c.glCompileShader(id);

    var success: c.GLint = undefined;
    c.glGetShaderiv(id, c.GL_COMPILE_STATUS, &success);
    if (success != 0) {
        return id;
    } else {
        var log_length: c.GLint = undefined;
        c.glGetShaderiv(id, c.GL_INFO_LOG_LENGTH, &log_length);
        const error_message = try std.heap.c_allocator.alloc(u8, @intCast(usize, log_length));
        c.glGetShaderInfoLog(id, log_length, &log_length, error_message.ptr);
        std.debug.panic("Error compiling shader:\n{}\n", .{error_message.ptr});
    }
}

/// Try to load a shader from a file with a given relative file path.
pub fn loadShaderFromFile(relative_path: []const u8, kind: ShaderKind) !c.GLuint {
    const allocator = std.heap.c_allocator;
    const file = try std.fs.cwd().openFile(relative_path, .{ .read = true });
    defer file.close();
    const shader_code = try file.readToEndAlloc(allocator, 1 << 20);
    return loadShader(shader_code, kind);
}
