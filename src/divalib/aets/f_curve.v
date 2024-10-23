module aets

import divalib.io

pub struct Key {
pub mut:
	frame   f32
	value   f32
	tangent f32
}

pub struct FCurve {
pub mut:
	keys []Key
}

pub fn (mut curve FCurve) read(mut br io.BinaryReader) {
	count := br.read_u32(false)
	curve.keys = []Key{len: int(count)}

	br.read_offset_and(fn [mut curve, mut br, count] () {
		if count == 1 {
			curve.keys[0].value = br.read_single(false)
			return
		}

		for i := 0; i < count; i++ {
			curve.keys[i].frame = br.read_single(false)
		}

		for i := 0; i < count; i++ {
			curve.keys[i].value = br.read_single(false)
			curve.keys[i].tangent = br.read_single(false)
		}
	})
}
