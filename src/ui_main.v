module main

import gg
import gx
import divalib.thirdparty.microui
import divalib.thirdparty.microui.enums

@[heap]
pub struct Window {
mut:
	ui microui.Context
pub mut:
	ctx &gg.Context = unsafe { nil }
}

pub fn (mut window Window) init_fn(_ voidptr) {
	window.ui = microui.new_context()

	window.ui.text_width = fn [mut window] (_ microui.Font, text &char, text_len int) int {
		return window.ctx.text_width(unsafe { cstring_to_vstring(text) })
	}

	window.ui.text_height = fn [mut window] (_ microui.Font) int {
		return window.ctx.text_height('LOVE')
	}
}

pub fn (mut window Window) draw_fn(_ voidptr) {
	window.ctx.begin()

	window.ui.begin()
	if window.ui.begin_window('Window', microui.Rect{70, 350, 300, 450}) {
		window.ui.text('Hello, world!')
		window.ui.label('Label')

		if window.ui.button('Click me') {
			println('CLICKED')
		}

		window.ui.end_window()
	}
	window.ui.end()

	command := &microui.Command(unsafe { nil })

	for window.ui.next_command(&command) {
		match command.@type {
			enums.command_rect {
				window.ctx.draw_rect_filled(f32(command.rect.rect.x), f32(command.rect.rect.y),
					f32(command.rect.rect.w), f32(command.rect.rect.h), gx.Color{u8(command.rect.color.r), u8(command.rect.color.g), u8(command.rect.color.b), u8(command.rect.color.a)})
			}
			enums.command_clip {
				window.ctx.scissor_rect(command.rect.rect.x, command.rect.rect.y, command.rect.rect.w,
					command.rect.rect.h)
			}
			enums.command_icon {
				x := command.rect.rect.x + (command.rect.rect.w - 16) / 2
				y := command.rect.rect.y + (command.rect.rect.h - 16) / 2

				window.ctx.draw_rect_filled(f32(x), f32(y), 16, 16, gx.Color{u8(command.rect.color.r), u8(command.rect.color.g), u8(command.rect.color.b), u8(command.rect.color.a)})
			}
			enums.command_text {
				window.ctx.draw_text(command.text.pos.x, command.text.pos.y, unsafe { cstring_to_vstring(command.text.str) },
					color: gx.Color{u8(command.text.color.r), u8(command.text.color.g), u8(command.text.color.b), u8(command.text.color.a)}
				)
			}
			else {}
		}
	}

	window.ctx.end()
}

fn main() {
	mut window := &Window{}

	window.ctx = gg.new_context(
		width:     1280
		height:    720
		user_data: window
		init_fn:   window.init_fn
		frame_fn:  window.draw_fn
	)

	window.ctx.run()
}
