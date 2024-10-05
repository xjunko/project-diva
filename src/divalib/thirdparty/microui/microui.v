module microui

// Context
pub fn new_context() &Context {
	mut ctx := unsafe { &Context(C.malloc(sizeof(Context))) }

	C.mu_init(ctx)

	ctx._style = default_style
	ctx.style = &default_style

	return ctx
}

// Operations
pub fn (mut ctx Context) begin() {
	C.mu_begin(ctx)
}

pub fn (mut ctx Context) end() {
	C.mu_end(ctx)
}

pub fn (mut ctx Context) begin_window(title string, rect Rect) bool {
	return C.mu_begin_window(ctx, title.str, rect)
}

pub fn (mut ctx Context) end_window() {
	C.mu_end_window(ctx)
}

pub fn (mut ctx Context) text(text string) {
	C.mu_text(ctx, text.str)
}

pub fn (mut ctx Context) label(text string) {
	C.mu_label(ctx, text.str)
}

pub fn (mut ctx Context) button(text string) bool {
	return C.mu_button(ctx, text.str)
}

pub fn (mut ctx Context) header(text string) bool {
	return C.mu_header(ctx, text.str)
}

pub fn (mut ctx Context) header_ex(text string, size int) bool {
	return C.mu_header_ex(ctx, text.str, size)
}

// &Context and &&Command
pub fn (mut ctx Context) next_command(command &&Command) bool {
	return C.mu_next_command(ctx, command)
}

// Inputs
pub enum MouseEvent {
	move
	down
	up
	scroll
}

pub fn (mut ctx Context) mouse_event(x int, y int, click int, ev MouseEvent) {
	match ev {
		.move {
			C.mu_input_mousemove(ctx, x, y)
		}
		.down {
			C.mu_input_mousedown(ctx, x, y, click)
		}
		.up {
			C.mu_input_mouseup(ctx, x, y, click)
		}
		.scroll {
			C.mu_input_scroll(ctx, x, y)
		}
	}
}
