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

	camera       &Camera = unsafe { nil }
	compositions []&Composition
	videos       []&Video
	audios       []&Audio
}

pub fn (mut scene Scene) read(mut br io.BinaryReader) {
	scene.name = br.read_string_offset(.null_terminated)
	scene.start_frame = br.read_single(false)
	scene.end_frame = br.read_single(false)
	scene.frame_rate = br.read_single(false)

	scene.background_color = br.read_vector4(.u8)
	scene.width = br.read_u32(false)
	scene.height = br.read_u32(false)

	camera_offset := br.read_u32(false)
	composition_count := br.read_u32(false)
	composition_offset := br.read_u32(false)
	video_count := br.read_u32(false)
	videos_offset := br.read_u32(false)
	audio_count := br.read_u32(false)
	audio_offset := br.read_u32(false)

	// Camera
	br.read_at_offset_and(camera_offset, fn [mut scene, mut br] () {
		scene.camera = &Camera{}
		scene.camera.read(mut br)
	})

	// Composition
	br.read_at_offset_and(composition_offset, fn [mut scene, mut br, composition_count] () {
		scene.compositions = []&Composition{len: int(composition_count), init: unsafe { nil }}

		for i := 0; i < composition_count; i++ {
			scene.compositions[i] = &Composition{}
			scene.compositions[i].read(mut br)
		}
	})

	// Video
	br.read_at_offset_and(videos_offset, fn [mut scene, mut br, video_count] () {
		scene.videos = []&Video{len: int(video_count), init: unsafe { nil }}

		for i := 0; i < video_count; i++ {
			scene.videos[i] = &Video{}
			scene.videos[i].read(mut br)
		}
	})

	// Audio
	br.read_at_offset_and(audio_offset, fn [mut scene, mut br, audio_count] () {
		scene.audios = []&Audio{len: int(audio_count), init: unsafe { nil }}

		for i := 0; i < audio_count; i++ {
			scene.audios[i] = &Audio{}
			scene.audios[i].read(mut br)
		}
	})
}
