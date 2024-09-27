module textures

import divalib.io

pub struct TextureSet {
mut:
	stream &io.BinaryReader
pub mut:
	textures []&Texture
}

pub fn (mut texture_set TextureSet) read() {
	texture_set.stream.push_offset()

	signature := texture_set.stream.read_u32(false)

	if signature != 0x03505854 {
		panic('[TextureSet] Invalid TextureSet Signature: ${signature}')
	}

	texture_count := texture_set.stream.read_u32(false)
	texture_count_with_rubbish := texture_set.stream.read_u32(false)

	for i := 0; i < texture_count; i++ {
		mut texture := &Texture{}

		texture_set.stream.read_offset_and(fn [mut texture, mut texture_set] () {
			texture.read(mut texture_set.stream)
		})

		texture_set.textures << texture
	}

	texture_set.stream.pop_offset()
}

pub fn TextureSet.from_io(mut br io.BinaryReader) &TextureSet {
	mut ts := &TextureSet{
		stream: unsafe { br }
	}

	return ts
}
