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
		br.position = offset

		texture_signature := br.read_u32(true)

		if texture_signature != 0x04505854 && texture_signature != 0x05505854 {
			panic('Invalid Texture Signature: ${texture_signature}')
		}

		println(texture_signature) // Signature
		br.position = current
		exit(1)
	}
}
