module textures

import divalib.io

pub struct Texture {
pub mut:
	id   u32
	name string
	size []u32

	subtextures [][]&SubTexture
}

pub fn (mut texture Texture) read(mut br io.BinaryReader) {
	br.push_offset()

	signature := br.read_u32(false)

	if signature != 0x04505854 && signature != 0x05505854 {
		panic('[Texture] Invalid Texture Signature: ${signature}')
	}

	subtexture_count := br.read_u32(false)
	subtexture_info := br.read_u32(false)

	mut mip_map_count := subtexture_info & 0xFF
	mut array_size := (subtexture_info >> 8) & 0xFF

	if array_size == 1 && mip_map_count != subtexture_count {
		mip_map_count = u8(subtexture_count)
	}

	texture.subtextures = [][]&SubTexture{}

	for i := 0; i < array_size; i++ {
		mut row := []&SubTexture{}

		for j := 0; j < mip_map_count; j++ {
			row << &SubTexture{}
		}

		texture.subtextures << row
	}

	for i := 0; i < array_size; i++ {
		for j := 0; j < mip_map_count; j++ {
			br.read_offset_and(fn [mut br, mut texture, i, j] () {
				texture.subtextures[i][j].read(mut br)
			})
		}
	}

	br.pop_offset()
}
