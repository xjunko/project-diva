module divagame

import sdl
import nsauzede.vnk
import framework.time.fps

pub struct Application {
pub:
	nuklear_version string = vnk.version
	sdl_version     string = sdl.major_version.str() + '.' + sdl.minor_version.str()
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

pub fn run() {
	mut application := Application.create()
	mut window := Window.create()
	mut renderer := Renderer.create(window)
	mut nuklear := Nuklear.create(window)
	mut events := Events.create()

	mut limiter := fps.new_limiter(60)

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
		limiter.sync()
	}

	nuklear.free()
	renderer.free()
	window.free()
	application.free()
}
