module textures

import divalib.io
import divalib.thirdparty.dxt

pub struct SubTexture {
pub mut:
	width  u32
	height u32
	format TextureFormat
	data   []u8
}

pub fn (mut sub_texture SubTexture) read(mut br io.BinaryReader) {
	signature := br.read_u32(false)

	if signature != 0x02505854 {
		panic('[SubTexture] Invalid SubTexture Signature: ${signature}')
	}

	sub_texture.width = br.read_u32(false)
	sub_texture.height = br.read_u32(false)
	sub_texture.format = unsafe { TextureFormat(br.read_u32(false)) }

	br.seek(4)

	data_size := br.read_u32(false)
	sub_texture.data = br.read_n(data_size)
}

pub fn (mut sub_texture SubTexture) decode() ([]u8, int) {
	mut channel_count := 0

	if !sub_texture.format.is_compressed() {
		// This should be easy, so I'm leaving it for later
		panic('Unimplemented uncompressed texture format')
	} else {
		// This is the hard part
		// This will be slowly implemented
		// For now we only support DXT5
		if sub_texture.format != .dxt5 {
			panic('Unimplemeted Texture Format: ${sub_texture.format}')
		}

		match sub_texture.format {
			.dxt5 {
				mut rgba_pixels := []u8{len: int(sub_texture.width * sub_texture.height * 16)}
				dxt.decompress_dxt5_to_rgba(sub_texture.width, sub_texture.height, sub_texture.data, mut
					rgba_pixels)
				return rgba_pixels, channel_count
			}
			else {}
		}
	}

	return []u8{}, channel_count
}
