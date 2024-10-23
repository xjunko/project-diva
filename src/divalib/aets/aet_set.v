module aets

import divalib.io

pub struct AetSet {
mut:
	stream &io.BinaryReader = unsafe { nil }
pub mut:
	scenes []&Scene
}

pub fn (mut aet_set AetSet) free() {
	panic('TODO!!!')
}

pub fn (mut aet_set AetSet) read() {
	for aet_set.stream.position < aet_set.stream.data.len {
		offset := aet_set.stream.read_offset()

		aet_set.stream.read_at_offset_and(offset, fn [mut aet_set] () {
			mut scene := &Scene{}
			scene.read(mut aet_set.stream)
			aet_set.scenes << unsafe { scene }
		})
	}
}

pub fn AetSet.from_file(path string) !&AetSet {
	mut br := io.BinaryReader.from_file(path)!
	mut aet_set := &AetSet{
		stream: unsafe { br }
	}

	return aet_set
}
