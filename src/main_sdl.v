module main

import sdl
import nsauzede.vnk

pub struct Application {
}

pub fn (mut application Application) free() {
	unsafe {
		sdl.quit()
	}
}

pub fn Application.create() &Application {
	mut app := &Application{}

	sdl.init(sdl.init_video | sdl.init_timer | sdl.init_events)

	return app
}

pub struct Window {
mut:
	p_window &sdl.Window
pub mut:
	width  int
	height int
}

pub fn (mut window Window) free() {
	unsafe {
		sdl.destroy_window(window.p_window)
	}
}

pub fn Window.create() &Window {
	mut window := &Window{
		p_window: sdl.create_window('Hello SDL2'.str, C.SDL_WINDOWPOS_CENTERED, C.SDL_WINDOWPOS_CENTERED,
			1280, 720, u32(C.SDL_WINDOW_OPENGL | C.SDL_WINDOW_SHOWN))
	}

	return window
}

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

pub struct Nuklear {
mut:
	ctx voidptr
}

pub fn (mut nuklear Nuklear) render() {
	C.nk_sdl_render(C.NK_ANTI_ALIASING_ON, 512 * 1024, 128 * 1024)
}

pub fn (mut nuklear Nuklear) free() {
	unsafe {
		C.nk_sdl_shutdown()
	}
}

pub fn Nuklear.create(window &Window) &Nuklear {
	mut nuklear := &Nuklear{
		ctx: C.nk_sdl_init(window.p_window)
	}

	atlas := unsafe { nil }
	C.nk_sdl_font_stash_begin(&atlas)
	C.nk_sdl_font_stash_end()

	return nuklear
}

pub struct Events {
mut:
	event sdl.Event
}

pub fn (mut events Events) poll_event(nuklear &Nuklear) bool {
	C.nk_input_begin(nuklear.ctx)

	for sdl.poll_event(&events.event) > 0 {
		match events.event.@type {
			.quit { return false }
			else {}
		}

		C.nk_sdl_handle_event(&events.event)
	}

	C.nk_input_end(nuklear.ctx)

	return true
}

pub fn Events.create() &Events {
	mut events := &Events{}
	return events
}

fn main() {
	mut application := Application.create()
	mut window := Window.create()
	mut renderer := Renderer.create(window)
	mut nuklear := Nuklear.create(window)
	mut events := Events.create()

	for events.poll_event(nuklear) {
		if 1 == C.nk_begin(nuklear.ctx, 'Nuklear Window'.str, C.nk_rect(50, 50, 230, 250),
			C.NK_WINDOW_BORDER | C.NK_WINDOW_MOVABLE | C.NK_WINDOW_SCALABLE | C.NK_WINDOW_MINIMIZABLE | C.NK_WINDOW_TITLE) {
			C.nk_layout_row_dynamic(nuklear.ctx, 30, 1)
			if 1 == C.nk_button_label(nuklear.ctx, 'Click Me'.str) {
				println('Pressed!')
			}
		}

		C.nk_end(nuklear.ctx)

		renderer.begin()
		renderer.clear_screen(0.4, 0.4, 0.4, 1)
		nuklear.render()
		renderer.update()
		renderer.end()
	}

	nuklear.free()
	renderer.free()
	window.free()
	application.free()
}
