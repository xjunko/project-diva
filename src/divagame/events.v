module divagame

import sdl

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
