module textures

import divalib.io

pub struct TextureSet {
mut:
	stream &io.BinaryReader
pub mut:
	textures []&Texture
}

pub fn (mut texture_set TextureSet) read() {
	signature := texture_set.stream.read_u32(false)

	if signature != 0x03505854 {
		panic('[TextureSet] Invalid TextureSet Signature: ${signature}')
	}

	texture_count := texture_set.stream.read_u32(false)
	texture_count_with_rubbish := texture_set.stream.read_u32(false)

	// This one is a bit hacky, fix it.
	// TODO: This is broken!!!
	for i := 0; i < texture_count; i++ {
		offset := texture_set.stream.read_u32(false)

		if offset == 0 || offset > texture_set.stream.data.len {
			break
		}

		current := texture_set.stream.position
		texture_set.stream.position += offset - 16 // Hack

		mut texture := &Texture{}
		texture.read(mut texture_set.stream)
		texture_set.textures << texture
	}
}

pub fn TextureSet.from_io(mut br io.BinaryReader) &TextureSet {
	mut ts := &TextureSet{
		stream: unsafe { br }
	}

	return ts
}
