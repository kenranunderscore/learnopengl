const std = @import("std");
const builtin = @import("builtin");

const c = @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});
const shader = @import("shader.zig");

const SCREEN_WIDTH: u32 = 800;
const SCREEN_HEIGHT: u32 = 600;

fn handleKey(win: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
    if (action != c.GLFW_PRESS) return;
    switch (key) {
        c.GLFW_KEY_ESCAPE => c.glfwSetWindowShouldClose(win, c.GL_TRUE),
        else => {},
    }
}

pub fn main() !void {
    const ok = c.glfwInit();
    if (ok == 0) {
        std.debug.panic("Failed to init GLFW\n", .{});
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GL_FALSE);

    var window = c.glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Learn OpenGL", null, null);
    if (window == null) {
        std.debug.panic("Failed to create window\n", .{});
    }
    defer c.glfwDestroyWindow(window);

    _ = c.glfwSetKeyCallback(window, handleKey);
    c.glfwMakeContextCurrent(window);

    const vertex_shader = try shader.loadShaderFromFile("shaders/triangle_vs.glsl", shader.ShaderKind.vertex);
    const fragment_shader = try shader.loadShaderFromFile("shaders/triangle_fs.glsl", shader.ShaderKind.fragment);
    const shader_program = c.glCreateProgram();
    c.glAttachShader(shader_program, vertex_shader);
    c.glAttachShader(shader_program, fragment_shader);
    c.glLinkProgram(shader_program);
    // TODO: check info log here
    c.glDeleteShader(vertex_shader);
    c.glDeleteShader(fragment_shader);

    const vertices = [_]f32{
        0.5,  0.5,  0.0,
        0.5,  -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5, 0.5,  0.0,
    };
    const indices = [_]u32{
        0, 1, 3,
        1, 2, 3,
    };

    var vao: c_uint = undefined;
    c.glGenVertexArrays(1, &vao);
    defer c.glDeleteVertexArrays(1, &vao);
    var vbo: c_uint = undefined;
    c.glGenBuffers(1, &vbo);
    defer c.glDeleteBuffers(1, &vbo);
    var ebo: c_uint = undefined;
    c.glGenBuffers(1, &ebo);
    defer c.glDeleteBuffers(1, &ebo);

    c.glBindVertexArray(vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);
    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, ebo);
    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(u32), &indices, c.GL_STATIC_DRAW);

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
    c.glBindVertexArray(0);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        c.glClearColor(0.2, 0.1, 0.2, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shader_program);
        c.glBindVertexArray(vao);
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}
