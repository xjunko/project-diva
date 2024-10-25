module aets

import divalib.io

pub enum LayerFlags {
	// Toggle video
	video_active = 1 << 0

	// Toggle audio
	audio_active = 1 << 1

	// ...?
	effects_active = 1 << 2

	// Toggle motion blur
	motion_blur    = 1 << 3
	frame_blending = 1 << 4

	// Toggle lock
	locked = 1 << 5

	// Hides the current layer
	shy           = 1 << 6
	collapse      = 1 << 7
	auto_rotation = 1 << 8

	adjustment_layer = 1 << 9
	time_remapping   = 1 << 10

	// 3D
	layer_is_3d = 1 << 11

	// ...?
	look_at_camera            = 1 << 12
	look_at_point_of_interest = 1 << 13

	// Renders only this layer in certain cases
	solo = 1 << 14

	markers_locked = 1 << 15
}

pub enum LayerQuality {
	none      = 0
	wireframe = 1
	draft     = 2
	best      = 3
}

pub struct Layer {
mut:
	reference_offset u32
	item_type        u32
	item_offset      u32
	parent_offset    u32
pub mut:
	name string

	start_time  f32
	end_time    f32
	offset_time f32
	time_scale  f32

	flags   LayerFlags
	quality LayerQuality

	item voidptr

	parent &Layer = unsafe { nil }

	markers []&Marker

	audio voidptr
	video voidptr
}

pub fn (mut layer Layer) read(mut br io.BinaryReader) {
	layer.reference_offset = u32(br.get_offset())

	layer.name = br.read_string_offset(.null_terminated)

	layer.start_time = br.read_single(false)
	layer.end_time = br.read_single(false)
	layer.offset_time = br.read_single(false)
	layer.time_scale = br.read_single(false)

	layer.flags = unsafe { LayerFlags(br.read_u16(false)) }
	layer.quality = unsafe { LayerQuality(br.read_byte()) }
	layer.item_type = br.read_byte()
	layer.item_offset = br.read_offset()
	layer.parent_offset = br.read_offset()

	marker_count := br.read_u32(false)
	marker_offset := br.read_offset()

	br.read_at_offset_and(marker_offset, fn [mut layer, mut br, marker_count] () {
		layer.markers = []&Marker{len: int(marker_count), init: unsafe { nil }}

		for i := 0; i < marker_count; i++ {
			println('[AET] Reading marker: ${i}/${marker_count}')
			layer.markers[i] = &Marker{}
			layer.markers[i].read(mut br)
		}
	})

	// Video
	br.read_offset_and(fn () {})
	// Audio
	br.read_offset_and(fn () {})
}
