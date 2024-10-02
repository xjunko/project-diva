module main

import os
import divalib.archives.farc
import divalib.sprites
import divalib.io
import divalib.textures
import stbi

fn main() {
	// Audio SFX (vag format)
	mut sfx_archive := farc.read('assets/dev/se_ft.farc')!

	for file in sfx_archive.entries {
		println('[SFX] Extracting ${file.name}')
		os.write_file_array('assets/dev/sfx/' + file.name, file.data)!
		file.free()
	}
	sfx_archive.free()

	// Sprites (bc formats)
	mut compressed_encrypted := farc.read('assets/dev/spr_gam_cmn.farc')!

	for entry in compressed_encrypted.entries {
		mut stream := io.BinaryReader.from_bytes(entry.data)
		mut sprite_set := sprites.SpriteSet.from_io(stream)
		sprite_set.read()

		for mut texture in sprite_set.texture_set.textures {
			println('Texture: ${texture.name}')
			println('Format: ${texture.subtextures[0][0].format}')
			println('Compressed: ${texture.subtextures[0][0].format.is_compressed()}')

			supported := [textures.TextureFormat.dxt1, textures.TextureFormat.dxt3,
				textures.TextureFormat.dxt5, .ati2, .ati1]

			if texture.subtextures[0][0].format !in supported {
				continue
			}

			for mut subtexture_row in texture.subtextures {
				for n, mut subtexture in subtexture_row {
					rgba_pixels, channel_count := subtexture.decode()

					stbi.set_flip_vertically_on_write(true)
					stbi.stbi_write_png('assets/dev/subtextures/' + texture.name +
						'_${n}_${subtexture.width}_${subtexture.height}_${subtexture.format.str()}.png',
						subtexture.width, subtexture.height, channel_count, rgba_pixels.data,
						subtexture.width * channel_count)!

					unsafe {
						rgba_pixels.free()
					}
				}
			}
		}

		sprite_set.free()
	}

	compressed_encrypted.free()

	for {}
}
