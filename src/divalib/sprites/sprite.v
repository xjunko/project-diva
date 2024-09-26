module sprites

import divalib.io

pub enum ResolutionMode {
	qvga
	vga
	svga
	xga
	mode4
	mode5
	uxga
	wvga
	mode8
	wxga
	mode10
	wuxga
	wqxga
	hdtv720
	hdtv1080
	mode15
	mode16
	mode17
	custom
}

pub struct Sprite {
pub mut:
	name          string
	resolution    ResolutionMode
	texture_index u32
	rect_begin    []f32
	rect_end      []f32
	position      []f32
	size          []f32
}

pub fn (mut sprite Sprite) read(mut br io.BinaryReader) {
	sprite.texture_index = br.read_u32(false)
	br.seek(4)

	sprite.rect_begin = br.read_singles(false, 2)
	sprite.rect_end = br.read_singles(false, 2)

	sprite.position = br.read_singles(false, 2)
	sprite.size = br.read_singles(false, 2)
}

pub fn (mut sprite Sprite) read_resolution(mut br io.BinaryReader) {
	br.seek(4)
	sprite.resolution = unsafe { ResolutionMode(br.read_u32(false)) }
}
