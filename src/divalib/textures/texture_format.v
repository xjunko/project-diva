module textures

import math

pub enum TextureFormat {
	unknown = -1
	a8      = 0
	rgb8    = 1
	rgba8   = 2
	rgb5    = 3
	rgb5a1  = 4
	rgba4   = 5
	dxt1    = 6
	dxt1a   = 7
	dxt3    = 8
	dxt5    = 9
	ati1    = 10
	ati2    = 11
	l8      = 12
	l8a8    = 13
}

pub fn (format TextureFormat) is_compressed() bool {
	return int(format) >= int(TextureFormat.dxt1) && int(format) <= int(TextureFormat.ati2)
}

pub fn (format TextureFormat) get_block_size() u32 {
	match format {
		.dxt1, .dxt1a, .ati1 {
			return 8
		}
		.dxt3, .dxt5, .ati2 {
			return 16
		}
		else {
			return 0
		}
	}
}

pub fn (format TextureFormat) get_data_size(width u32, height u32) u32 {
	match format {
		.a8, .l8 {
			return width * height
		}
		.rgb8 {
			return width * height * 3
		}
		.rgba8 {
			return width * height * 4
		}
		.rgb5, .rgb5a1, .rgba4, .l8a8 {
			return width * height * 2
		}
		else {
			return math.max(u32(1), (width + 3) / 4 * math.max(u32(1), (height + 3) / 4)) * format.get_block_size()
		}
	}
}
