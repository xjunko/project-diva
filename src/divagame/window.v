module divagame

import sdl

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
