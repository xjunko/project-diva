module sprites

import divalib.io

pub struct SpriteSet {
mut:
	stream &io.BinaryReader
pub mut:
	sprites []&Sprite
}

pub fn SpriteSet.from_io(stream &io.BinaryReader) &SpriteSet {
	mut ss := &SpriteSet{
		stream: unsafe { stream }
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
}
