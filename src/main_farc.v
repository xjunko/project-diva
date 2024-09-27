module main

import os
import divalib.archives.farc
import divalib.sprites
import divalib.io

fn main() {
	mut compressed_only := farc.read('assets/dev/gm_btn_se_tbl.farc')!
	mut compressed_encrypted := farc.read('assets/dev/spr_gam_cmn.farc')!

	for entry in compressed_only.entries {
		println(entry.name)
	}

	for entry in compressed_encrypted.entries {
		os.write_file_array('assets/dev/raw/' + entry.name, entry.data)!
	}

	mut stream := io.BinaryReader.from_file('assets/dev/raw/spr_gam_cmn_ref.bin')!
	mut sprite_set := sprites.SpriteSet.from_io(stream)
	sprite_set.read()

	for mut texture in sprite_set.texture_set.textures {
		println('Texture: ${texture.name}')
		println('Format: ${texture.subtextures[0][0].format}')
		println('Compressed: ${texture.subtextures[0][0].format.is_compressed()}')

		for mut subtexture_row in texture.subtextures {
			for n, mut subtexture in subtexture_row {
				subtexture.decode()
				os.write_file_array('assets/dev/subtextures/' + texture.name + '_${n}.png',
					subtexture.data)!
			}
		}
	}
}
