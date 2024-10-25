module aets

import divalib.io

pub struct Audio {
mut:
	reference_offset u32
pub mut:
	sound_id u32
}

pub fn (mut audio Audio) read(mut br io.BinaryReader) {
	audio.reference_offset = u32(br.get_offset())

	audio.sound_id = br.read_u32(false)
}
