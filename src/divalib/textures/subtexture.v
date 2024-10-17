module textures

import arrays
import divalib.io
import thirdparty.bcdec

pub struct SubTexture {
pub mut:
	width  u32
	height u32
	format TextureFormat
	data   []u8
}

pub fn (sub_texture &SubTexture) free() {
	// Nothing to free, because data is just a reference to binaryreader upstream.
	// Those will get freed instead.
	// panic("Don't free SubTexture, refer to ${@FILE}:${@LINE}")
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
		match sub_texture.format {
			.rgba8 {
				channel_count = 4
				return unsafe { sub_texture.data }, channel_count
			}
			else {
				panic('Unsupported texture format: ${sub_texture.format}')
			}
		}
	} else {
		match sub_texture.format {
			.dxt1 {
				mut rgba_pixels := bcdec.get_dxt1(sub_texture.data, sub_texture.width,
					sub_texture.height)
				channel_count = 4
				return rgba_pixels, channel_count
			}
			.dxt3 {
				mut rgba_pixels := bcdec.get_dxt3(sub_texture.data, sub_texture.width,
					sub_texture.height)
				channel_count = 4
				return rgba_pixels, channel_count
			}
			.dxt5 {
				mut rgba_pixels := bcdec.get_dxt5(sub_texture.data, sub_texture.width,
					sub_texture.height)
				channel_count = 4
				return rgba_pixels, channel_count
			}
			.ati1 {
				mut pixels := bcdec.get_ati1(sub_texture.data, sub_texture.width, sub_texture.height)
				channel_count = 1

				panic("This is WIP, I haven't tested it yet")
				return pixels, channel_count
			}
			.ati2 {
				mut pixels := bcdec.get_ati2(sub_texture.data, sub_texture.width, sub_texture.height)
				channel_count = 2
				return pixels, channel_count
			}
			else {
				panic('Unsupported texture format: ${sub_texture.format}')
			}
		}
	}

	return []u8{}, channel_count
}
