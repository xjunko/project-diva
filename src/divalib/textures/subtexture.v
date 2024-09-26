module textures

import divalib.io

pub struct SubTexture {
pub mut:
	width  u32
	height u32
	format u32
	data   []u8
}

pub fn (mut sub_texture SubTexture) read(mut br io.BinaryReader) {
	signature := br.read_u32(false)

	if signature != 0x02505854 {
		panic('[SubTexture] Invalid SubTexture Signature: ${signature}')
	}

	sub_texture.width = br.read_u32(false)
	sub_texture.height = br.read_u32(false)
	sub_texture.format = br.read_u32(false)

	br.seek(4)

	data_size := br.read_u32(false)
	sub_texture.data = br.read_n(data_size)
}
