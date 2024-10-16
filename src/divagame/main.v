module divagame

import os
import sdl
import nsauzede.vnk
import framework.time.fps
import divalib.archives.farc
import divalib.archives.farc.structs

pub struct Application {
pub:
	nuklear_version string = vnk.version
	sdl_version     string = sdl.major_version.str() + '.' + sdl.minor_version.str()
mut:
	farc_files []string

	has_loaded   bool
	current_farc &structs.IArchive
}

pub fn (mut application Application) setup_files() {
	application.farc_files = os.glob('assets/dev/farcs/*.farc') or { panic(err) }
}

pub fn (mut application Application) load_farc(index int) {
	if application.has_loaded {
		println('[Application] Freeing current FARC!')
		unsafe {
			for i := 0; i < application.current_farc.entries.len; i++ {
				application.current_farc.entries[i].data.free()
			}
			application.current_farc.free()
		}
		application.has_loaded = false
	}

	println('[Application] Loading FARC: ${application.farc_files[index]}')
	application.current_farc = farc.read(application.farc_files[index]) or { panic(err) }
	application.has_loaded = true
}

pub fn (mut application Application) free() {
	unsafe {
		sdl.quit()
	}
}

pub fn Application.create() &Application {
	mut app := &Application{
		current_farc: unsafe { nil }
	}

	sdl.init(sdl.init_video | sdl.init_timer | sdl.init_events)
	app.setup_files()

	return app
}

fn C.nk_combo(voidptr, voidptr, int, int, int, C.nk_vec2) int

pub fn run() {
	mut application := Application.create()
	mut window := Window.create()
	mut renderer := Renderer.create(window)
	mut nuklear := Nuklear.create(window)
	mut events := Events.create()

	mut limiter := fps.new_limiter(60)

	farc_files := application.farc_files.clone().map(it.split('/')#[-1..][0].str)

	mut current_farc_option := 0
	mut current_loaded_farc := -1

	for events.poll_event(nuklear) {
		if 1 == C.nk_begin(nuklear.ctx, 'DivaGame'.str, C.nk_rect(50, 50, 350, 200), C.NK_WINDOW_BORDER | C.NK_WINDOW_MOVABLE | C.NK_WINDOW_SCALABLE | C.NK_WINDOW_MINIMIZABLE | C.NK_WINDOW_TITLE) {
			// FARC Loader
			// vfmt off
			
			C.nk_layout_row_static(nuklear.ctx, 25, 150, 2)
				C.nk_label(nuklear.ctx, 'FARC Files:'.str, C.NK_TEXT_LEFT)
				current_farc_option = C.nk_combo(nuklear.ctx, farc_files.data, farc_files.len, current_farc_option, 25, C.nk_vec2{200, 200})

				if current_farc_option != current_loaded_farc {
					current_loaded_farc = current_farc_option
					application.load_farc(current_farc_option)
				}

				if application.has_loaded {
					C.nk_label(nuklear.ctx, 'Header:'.str, C.NK_TEXT_LEFT)
					C.nk_label(nuklear.ctx, application.current_farc.get_header().str, C.NK_TEXT_LEFT)

					C.nk_label(nuklear.ctx, 'Entries:'.str, C.NK_TEXT_LEFT)
					C.nk_label(nuklear.ctx, application.current_farc.entries.len.str().str, C.NK_TEXT_LEFT)
				}
			// vfmt on
		}

		C.nk_end(nuklear.ctx)

		renderer.begin()
		renderer.clear_screen(0.4, 0.4, 0.4, 1)
		nuklear.render()
		renderer.update()
		renderer.end()
		limiter.sync()
	}

	unsafe {
		application.farc_files.free()
		farc_files.free()
	}
	nuklear.free()
	renderer.free()
	window.free()
	application.free()
}
