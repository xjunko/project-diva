module main

import os
import divalib.archives.farc
import divalib.sprites
import divalib.io
import stbi

fn main() {
	mut compressed_encrypted := farc.read('assets/dev/spr_gam_cmn.farc')!

	for entry in compressed_encrypted.entries {
		mut stream := io.BinaryReader.from_bytes(entry.data)
		mut sprite_set := sprites.SpriteSet.from_io(stream)
		sprite_set.read()

		for mut texture in sprite_set.texture_set.textures {
			println('Texture: ${texture.name}')
			println('Format: ${texture.subtextures[0][0].format}')
			println('Compressed: ${texture.subtextures[0][0].format.is_compressed()}')

			// We only support DXT5, DXT1 right now
			if texture.subtextures[0][0].format != .dxt5
				&& texture.subtextures[0][0].format != .dxt1 {
				continue
			}

			for mut subtexture_row in texture.subtextures {
				for n, mut subtexture in subtexture_row {
					rgba_pixels, channel_count := subtexture.decode()

					stbi.set_flip_vertically_on_write(true)
					stbi.stbi_write_png('assets/dev/subtextures/' + texture.name +
						'_${n}_${subtexture.width}_${subtexture.height}.png', subtexture.width,
						subtexture.height, 4, rgba_pixels.data, subtexture.width * channel_count)!

					unsafe {
						rgba_pixels.free()
					}
				}
			}
		}
	}
}
