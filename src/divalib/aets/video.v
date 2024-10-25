module aets

import math.vec
import divalib.io

pub struct VideoSource {
pub mut:
	name string
	id   u32
}

pub fn (mut video_source VideoSource) read(mut br io.BinaryReader) {
	video_source.name = br.read_string(.null_terminated)
	video_source.id = br.read_u32(false)
}

pub struct Video {
mut:
	reference_offset u32
pub mut:
	color  vec.Vec4[f32]
	width  u16
	height u16
	frames f32

	sources []&VideoSource
}

pub fn (mut video Video) read(mut br io.BinaryReader) {
	video.reference_offset = u32(br.get_offset())

	video.color = br.read_vector4(.u8)
	video.width = br.read_u16(false)
	video.height = br.read_u16(false)
	video.frames = br.read_single(false)

	source_count := br.read_u32(false)

	br.read_offset_and(fn [mut video, mut br, source_count] () {
		video.sources = []&VideoSource{len: int(source_count), init: unsafe { nil }}

		for i := 0; i < int(source_count); i++ {
			video.sources[i] = &VideoSource{}
			video.sources[i].read(mut br)
		}
	})
}
