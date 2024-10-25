module divacmd

import os
import stbi
import divalib.io
import divalib.aets
import divalib.sprites
import divalib.archives.farc

fn init() {
	stbi.set_flip_vertically_on_write(true)
}

fn audio_archives() ! {
	// // vgmstream-wrapper
	// mut sfx_test := io.VAGReader.from_file('assets/dev/sfx/se_ft_common_01.vag')
	// sfx_test.read()!

	// Audio SFX (vag format)
	mut sfx_archive := farc.read('assets/dev/farcs/button.farc')!

	//
	mut audio := (sfx_archive.get_file('01_button1.vag')!).to_vag_audio()
	audio.read()!
	os.write_file_array('assets/dev/sfx/' + 'test' + '.wav', audio.data)!

	// To WAV
	for file in sfx_archive.entries {
		println('[SFX] Extracting ${file.name}')
		mut wav := io.VAGReader.from_bytes(file.data)
		wav.read()!
		os.write_file_array('assets/dev/sfx/' + file.name + '.wav', wav.data)!
		file.free()
	}

	sfx_archive.free()
}

fn farc_archives() ! {
	// Sprites (bc formats)
	mut compressed_encrypted := farc.read('assets/dev/taion/spr_gam_pv261.farc')!

	for entry in compressed_encrypted.entries {
		mut stream := io.BinaryReader.from_bytes(entry.data)
		mut sprite_set := sprites.SpriteSet.from_io(stream)
		sprite_set.read()

		for sprite in sprite_set.sprites {
			println(sprite)
		}

		for mut texture in sprite_set.texture_set.textures {
			println('Texture: ${texture.name}')
			println('Format: ${texture.subtextures[0][0].format}')
			println('Compressed: ${texture.subtextures[0][0].format.is_compressed()}')

			for mut subtexture_row in texture.subtextures {
				for n, mut subtexture in subtexture_row {
					subtexture_data, subtexture_channels := subtexture.decode()

					stbi.stbi_write_tga('assets/dev/subtextures/' + texture.name +
						'_${subtexture.format}_${n}.tga', subtexture.width, subtexture.height,
						subtexture_channels, subtexture_data.data)!

					unsafe {
						subtexture_data.free()
					}
				}

				for subtexture in subtexture_row {
					unsafe {
						subtexture.free()
					}
				}
			}
		}

		sprite_set.free()
	}

	compressed_encrypted.free()
}

pub fn aet_test() ! {
	mut aet_sets := aets.AetSet.from_file('assets/dev/aet_gam_pv221.bin')!
	aet_sets.read()
}

pub fn run() ! {
	// farc_archives()!
	audio_archives()!
}
