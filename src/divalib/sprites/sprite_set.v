module sprites

import divalib.io
import divalib.textures

pub struct SpriteSet {
mut:
	stream &io.BinaryReader
pub mut:
	sprites     []&Sprite
	texture_set &textures.TextureSet
}

pub fn SpriteSet.from_io(stream &io.BinaryReader) &SpriteSet {
	mut ss := &SpriteSet{
		stream:      unsafe { stream }
		texture_set: unsafe { 0 }
	}

	return ss
}

pub fn (mut sprite_set SpriteSet) read() {
	signature := sprite_set.stream.read_u32(false)
	texture_offset := sprite_set.stream.read_u32(false)
	texture_count := sprite_set.stream.read_u32(false)
	sprite_count := sprite_set.stream.read_u32(false)
	sprite_offset := sprite_set.stream.read_u32(false)
	texture_name_offset := sprite_set.stream.read_u32(false)
	sprite_name_offset := sprite_set.stream.read_u32(false)
	sprite_model_offset := sprite_set.stream.read_u32(false)

	// Sprite Info
	sprite_set.stream.to(sprite_offset)

	for i := 0; i < sprite_count; i++ {
		mut sprite := &Sprite{}
		sprite.read(mut sprite_set.stream)
		sprite_set.sprites << sprite
	}

	// Sprite Name
	sprite_set.stream.to(sprite_name_offset)

	for i := 0; i < sprite_count; i++ {
		sprite_set.sprites[i].name = sprite_set.stream.read_string_offset(.null_terminated)
	}

	// Sprite Read Mode
	sprite_set.stream.to(sprite_model_offset)

	for i := 0; i < sprite_count; i++ {
		sprite_set.sprites[i].read_resolution(mut sprite_set.stream)
	}

	// Texture
	sprite_set.stream.to(texture_offset)

	sprite_set.texture_set = textures.TextureSet.from_io(mut sprite_set.stream)
	sprite_set.texture_set.read()

	// Texture Name
	// TODO: Checkout the TextureSet Read function, it's broken atm, hence the check below.
	sprite_set.stream.to(texture_name_offset)

	for i := 0; i < texture_count; i++ {
		if i >= sprite_set.texture_set.textures.len {
			break
		}
		sprite_set.texture_set.textures[i].name = sprite_set.stream.read_string_offset(.null_terminated)
	}
}
