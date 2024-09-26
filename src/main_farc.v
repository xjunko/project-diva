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

	br.position = 12 // Figure this shit out

	println(br.read_u32(false)) // SpriteSetCount
	println(br.read_u32(false)) // SpriteSetOffset
	println(br.read_u32(false)) // SpriteCount
	println(br.read_u32(false)) // SpriteOffset
}
