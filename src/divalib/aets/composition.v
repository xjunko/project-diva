module aets

import divalib.io

pub struct Composition {
mut:
	reference_offset u32
pub mut:
	layers []&Layer
}

pub fn (mut composition Composition) read(mut br io.BinaryReader) {
	composition.reference_offset = u32(br.get_offset())

	layer_count := br.read_u32(false)
	offset := br.read_offset()

	br.read_at_offset_and(offset, fn [mut composition, mut br, layer_count] () {
		composition.layers = []&Layer{len: int(layer_count), init: unsafe { nil }}

		for i := 0; i < layer_count; i++ {
			composition.layers[i] = &Layer{}
			composition.layers[i].read(mut br)
		}
	})
}
