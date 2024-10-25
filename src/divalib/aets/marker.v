module aets

import divalib.io

pub struct Marker {
pub mut:
	frame f32
	name  string
}

pub fn (mut marker Marker) read(mut br io.BinaryReader) {
	marker.frame = br.read_single(false)
	marker.name = br.read_string_offset(.null_terminated)
}
