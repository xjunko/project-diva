module divagame

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
