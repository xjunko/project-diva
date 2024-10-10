module textures

import divalib.io
import divalib.thirdparty.bcdec

pub struct Texture {
pub mut:
	id   u32
	name string
	size []u32

	subtextures [][]&SubTexture
}

pub fn (texture &Texture) free() {
	unsafe {
		texture.size.free()

		for i := 0; i < texture.subtextures.len; i++ {
			for j := 0; j < texture.subtextures[i].len; j++ {
				texture.subtextures[i][j].free()
			}
		}
	}
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

	texture.subtextures = [][]&SubTexture{len: int(array_size), init: unsafe { nil }}
	for i := 0; i < array_size; i++ {
		texture.subtextures[i] = []&SubTexture{len: int(mip_map_count), init: &SubTexture{}}
	}

	for i := 0; i < array_size; i++ {
		for j := 0; j < mip_map_count; j++ {
			br.read_offset_and(fn [mut br, mut texture, i, j] () {
				texture.subtextures[i][j].read(mut br)
			})
		}
	}

	br.pop_offset()

	// BC5 (ati2), has 2 mipmaps, one is luminance and the other is half-sized chroma
	// this combines it into one RGBA8 texture
	for i := 0; i < array_size; i++ {
		for j := 0; j < mip_map_count; j++ {
			if texture.subtextures[i][j].format == TextureFormat.ati2 {
				texture.process_unique_subtextures()
				return
			}
		}
	}
}

pub fn (mut texture Texture) process_unique_subtextures() {
	assert texture.subtextures[0].len == 2
	assert texture.subtextures[0][0].format == TextureFormat.ati2
	assert texture.subtextures[0][1].format == TextureFormat.ati2
	assert texture.subtextures[0][0].width / 2 == texture.subtextures[0][1].width
	assert texture.subtextures[0][0].height / 2 == texture.subtextures[0][1].height

	lum_pixels, lum_channel_count := texture.subtextures[0][0].decode()
	chr_pixels, chr_channel_count := texture.subtextures[0][1].decode()

	mut final_pixels := bcdec.get_ati2_ycbcr(lum_pixels, chr_pixels, texture.subtextures[0][0].width,
		texture.subtextures[0][0].height, lum_channel_count, chr_channel_count)

	unsafe {
		lum_pixels.free()
		chr_pixels.free()
	}
	mut rgba_texture := &SubTexture{
		width:  texture.subtextures[0][0].width
		height: texture.subtextures[0][0].height
		format: TextureFormat.rgba8
		data:   &final_pixels
	}

	texture.subtextures[0] = []&SubTexture{len: 1, init: unsafe { nil }}
	texture.subtextures[0][0] = rgba_texture
}
