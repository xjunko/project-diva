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

	mut stream := io.BinaryReader.from_file('assets/dev/raw/spr_gam_cmn.bin')!
	mut sprite_set := sprites.SpriteSet.from_io(stream)
	sprite_set.read()

	println(sprite_set.sprites)
	println(sprite_set.texture_set.textures)
}
