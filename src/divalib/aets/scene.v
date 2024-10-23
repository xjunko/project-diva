module aets

import divalib.io
import math.vec

pub struct Scene {
pub mut:
	name string

	start_frame f32
	end_frame   f32
	frame_rate  f32

	background_color vec.Vec4[f32]
	width            int
	height           int

	camera &Camera = unsafe { nil }
}

pub fn (mut scene Scene) read(mut br io.BinaryReader) {
	scene.name = br.read_string_offset(.null_terminated)
	scene.start_frame = br.read_single(false)
	scene.end_frame = br.read_single(false)
	scene.frame_rate = br.read_single(false)

	scene.background_color = br.read_vector4(.u8)
	scene.width = br.read_u32(false)
	scene.height = br.read_u32(false)

	camera_offset := br.read_offset()
	composition_count := br.read_u32(false)
	composition_offset := br.read_offset()
	video_count := br.read_u32(false)
	videos_offset := br.read_offset()
	audio_count := br.read_u32(false)
	audio_offset := br.read_offset()

	br.read_at_offset_and(camera_offset, fn [mut scene, mut br] () {
		scene.camera = &Camera{}
		scene.camera.read(mut br)
	})
	exit(1)
}
