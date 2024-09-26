module main

import os
import divalib.farc
import divalib.farc.utils

fn main() {
	mut compressed_only := farc.read('assets/dev/gm_btn_se_tbl.farc')!
	mut compressed_encrypted := farc.read('assets/dev/spr_gam_cmn.farc')!

	for entry in compressed_only.entries {
		println(entry.name)
	}

	for entry in compressed_encrypted.entries {
		os.write_file_array('assets/dev/raw/' + entry.name, entry.data)!
	}

	// AET Sprite Database ? Maybe
	mut br := utils.BinaryReader.from_file('assets/dev/raw/spr_gam_cmn_ref.bin')!

	println(br.read_u32(false)) // Signature
	texture_offset := br.read_u32(false)
	println(texture_offset) // TextureOffset
	texture_count := br.read_u32(false)
	println(texture_count) // TextureCount
	sprite_count := br.read_u32(false)
	println(sprite_count) // SpriteCount
	sprite_offset := br.read_u32(false)
	println(sprite_offset) // SpriteOffset
	println(br.read_u32(false)) // TextureNameOffset
	sprite_name_offset := br.read_u32(false)
	println(sprite_name_offset) // SpriteNameOffset
	println(br.read_u32(false)) // SpriteModeOffset

	// Sprites
	br.position = sprite_offset
	for i := 0; i < sprite_count; i++ {
		println(br.read_u32(false)) // TextureIndex
		br.position += 4

		// 1065353216
		println(br.read_u32(false)) // X0
		println(br.read_u32(false)) // X1

		println(br.read_u32(false)) // Y0
		println(br.read_u32(false)) // Y1

		println(br.read_u32(false)) // X Pos
		println(br.read_u32(false)) // Y Pos

		println(br.read_u32(false)) // Width
		println(br.read_u32(false)) // Height
	}

	// Sprite Names
	br.position = sprite_name_offset

	for i := 0; i < sprite_name_offset; i++ {
		offset := br.read_u32(false)

		if offset == 0 {
			break
		}

		current := br.position
		br.position = offset
		print(br.read_string(.null_terminated) + ', ')
		br.position = current
	}
	println('')

	// Texture Set
	br.position = texture_offset

	texture_set_signature := br.read_u32(false)

	if texture_set_signature != 0x03505854 {
		panic('Invalid Texture Set Signature')
	}

	println(texture_set_signature) // Signature
	println(br.read_u32(false)) // TextureCount
	println(br.read_u32(false)) // TextureCountWithRubbish

	for i := 0; i < texture_count; i++ {
		offset := br.read_u32(false)

		if offset == 0 {
			break
		}

		current := br.position
		br.position += offset - 16 // Hack

		texture_signature := br.read_u32(false)

		if texture_signature != 0x04505854 && texture_signature != 0x05505854 {
			panic('Invalid Texture Signature: ${texture_signature}')
		}

		sub_text_count := br.read_u32(false)
		println(sub_text_count) // subTextureCount

		sub_text_info := br.read_u32(false)
		println(sub_text_info) // subTextInfo

		mut mip_map_count := sub_text_info & 0xFF
		array_size := (sub_text_info >> 8) & 0xFF

		if array_size == 1 && mip_map_count != sub_text_count {
			mip_map_count = u8(sub_text_count)
		}

		for j := 0; j < array_size; j++ {
			for k := 0; k < mip_map_count; k++ {
				mipmap_offset := br.read_u32(false)

				if mipmap_offset == 0 {
					break
				}

				mipmap_current := br.position
				br.position += mipmap_offset - 16 // Hack

				println(mipmap_offset)
				subtexture_signature := br.read_u32(false)

				if subtexture_signature != 0x02505854 {
					panic('Invalid SubTexture Signature: ${subtexture_signature}')
				}

				println(br.read_u32(false)) // Width
				println(br.read_u32(false)) // Height
				println(br.read_u32(false)) // Format

				br.position += 4

				data_size := br.read_u32(false)
				println(data_size) // DataSize
				subtexture_data := br.read_n(data_size)

				br.position = mipmap_current
				exit(1)
			}
		}

		br.position = current
		exit(1)
	}
}
