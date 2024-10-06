module main

import os
import stbi
import divalib.io
import divalib.sprites
import divalib.textures
import divalib.archives.farc
import divalib.thirdparty.bcdec

fn init() {
	stbi.set_flip_vertically_on_write(true)
}

fn audio_archives() ! {
	// vgmstream-wrapper
	mut sfx_test := io.VAGReader.from_file('assets/dev/sfx/se_ft_common_01.vag')
	sfx_test.read()!

	// Audio SFX (vag format)
	mut sfx_archive := farc.read('assets/dev/se_ft.farc')!

	for file in sfx_archive.entries {
		println('[SFX] Extracting ${file.name}')
		os.write_file_array('assets/dev/sfx/' + file.name, file.data)!
		file.free()
	}
	sfx_archive.free()
}

fn main() {
	// Sprites (bc formats)
	mut compressed_encrypted := farc.read('assets/dev/spr_gam_cmn.farc')!

	for entry in compressed_encrypted.entries {
		mut stream := io.BinaryReader.from_bytes(entry.data)
		mut sprite_set := sprites.SpriteSet.from_io(stream)
		sprite_set.read()

		for mut texture in sprite_set.texture_set.textures {
			supported := [textures.TextureFormat.ati2]

			if texture.subtextures[0][0].format !in supported {
				continue
			}

			println('Texture: ${texture.name}')
			println('Format: ${texture.subtextures[0][0].format}')
			println('Compressed: ${texture.subtextures[0][0].format.is_compressed()}')

			for mut subtexture_row in texture.subtextures {
				mut lum_texture := subtexture_row[0]
				mut chr_texture := subtexture_row[1]

				lum_pixels, lum_channel_count := lum_texture.decode()
				chr_pixels, chr_channel_count := chr_texture.decode()

				final_pixels := bcdec.get_ati2_ycbcr(lum_pixels, chr_pixels, lum_texture.width,
					lum_texture.height, lum_channel_count, chr_channel_count)

				stbi.stbi_write_tga('assets/dev/subtextures/' + texture.name + '.tga',
					lum_texture.width, lum_texture.height, 4, final_pixels.data)!

				unsafe {
					lum_pixels.free()
					chr_pixels.free()
					final_pixels.free()
				}
			}
		}

		sprite_set.free()
	}

	compressed_encrypted.free()

	for {}
}
