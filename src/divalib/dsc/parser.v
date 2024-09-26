module dsc

import os
import encoding.binary
import dsc.opcodes

pub struct DSCParser {
pub mut:
	commands []opcodes.OPCode
}

pub fn DSCParser.from_file(path string) !DSCParser {
	raw_bytes := os.read_bytes(path)!

	mut diva_script := DSCParser{}

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
			diva_script.commands << current_operation
		}
	}

	return diva_script
}
