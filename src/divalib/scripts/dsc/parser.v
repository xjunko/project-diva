module dsc

import os
import encoding.binary
import dsc.opcodes

pub struct DSCEvent {
pub mut:
	action     string
	start_time f64
	end_time   f64
	values     []int
}

pub struct DSCParser {
pub mut:
	commands []DSCEvent
}

fn (mut parser DSCParser) normalize(commands []opcodes.OPCode) ! {
	// Emulates the game loop to get the right timing and everything.
	mut current_line := 0
	mut current_time := f64(0.0)
	mut current_offset := f64(1000.0)

	for current_line < commands.len {
		current_opcode := commands[current_line]

		match current_opcode.action {
			'TIME' {
				current_time = DSCParser.diva_time_to_standard_milliseconds(current_opcode.arguments[0])
			}
			'LYRIC' {
				parser.commands << DSCEvent{
					action:     current_opcode.action
					start_time: current_time
					end_time:   current_time
					values:     current_opcode.arguments
				}
			}
			'MUSIC_PLAY' {
				parser.commands << DSCEvent{
					action:     current_opcode.action
					start_time: current_time
					end_time:   current_time
				}
			}
			'TARGET' {
				parser.commands << DSCEvent{
					action:     current_opcode.action
					start_time: current_time + current_offset
					end_time:   current_time + current_offset
					values:     current_opcode.arguments
				}
			}
			'BAR_TIME_SET' {
				current_offset = f64(current_opcode.arguments[0]) * 4.0
			}
			'TARGET_FLYING_TIME' {
				current_offset = f64(current_opcode.arguments[0])
			}
			else {}
		}

		current_line++
	}

	parser.commands.sort(a.start_time < b.start_time)
}

pub fn DSCParser.from_file(path string) !DSCParser {
	raw_bytes := os.read_bytes(path)!

	mut diva_script := DSCParser{}
	mut commands := []opcodes.OPCode{}

	// Start reading, 4 bytes for each header
	for i := 0; i < raw_bytes.len; i += 4 {
		current_opcode := int(binary.little_endian_u32(raw_bytes[i..i + 4]))

		// Try to parse, if exists in list
		if current_opcode in opcodes.codes {
			mut current_operation := opcodes.codes[current_opcode].clone()

			for j := 0; j < current_operation.length; j++ {
				i += 4
				current_operation.arguments << int(binary.little_endian_u32(raw_bytes[i..i + 4]))
			}

			// NOTE: Empty arguments OPCodes are also included, we might not need to include them
			commands << current_operation
		}
	}

	diva_script.normalize(commands)!

	return diva_script
}
