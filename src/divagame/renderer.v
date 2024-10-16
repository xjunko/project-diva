module divagame

import sdl

pub struct Renderer {
mut:
	window &Window

	p_gl_context sdl.GLContext
}

pub fn (mut renderer Renderer) begin() {
	C.glViewport(0, 0, &renderer.window.width, &renderer.window.height)
}

pub fn (mut renderer Renderer) clear_screen(r f32, g f32, b f32, a f32) {
	C.glClear(C.GL_COLOR_BUFFER_BIT)
	C.glClearColor(r, g, b, a)
}

pub fn (mut renderer Renderer) update() {
	sdl.gl_swap_window(renderer.window.p_window)
}

pub fn (mut renderer Renderer) end() {
}

pub fn (mut renderer Renderer) free() {
	unsafe {
		sdl.gl_delete_context(renderer.p_gl_context)
	}
}

pub fn Renderer.create(window &Window) &Renderer {
	mut renderer := &Renderer{
		window:       unsafe { window }
		p_gl_context: sdl.gl_create_context(window.p_window)
	}

	sdl.gl_set_attribute(.context_flags, C.SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
	sdl.gl_set_attribute(.context_profile_mask, C.SDL_GL_CONTEXT_PROFILE_CORE)
	sdl.gl_set_attribute(.context_major_version, 3)
	sdl.gl_set_attribute(.context_minor_version, 3)
	sdl.gl_set_attribute(.doublebuffer, 1)

	sdl.gl_get_drawable_size(window.p_window, &window.width, &window.height)
	C.glViewport(0, 0, &window.width, &window.height)

	if C.glewInit() != C.GLEW_OK {
		panic('Failed to initialize GLEW')
	}

	return renderer
}
