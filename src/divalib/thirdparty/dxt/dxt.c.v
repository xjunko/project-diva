module dxt

#flag -I @VMODROOT/c
#include "s3tc.h"
#include "s3tc.cpp"

pub fn C.PackRGBA(u8, u8, u8, u8) u64
pub fn C.UnpackRGBA(u64, &u8, &u8, &u8, &u8)

pub fn C.DecompressBlockDXT5(u64, u64, u64, &u8, &u64)
pub fn C.BlockDecompressImageDXT5(u64, u64, &u8, &u64)

pub fn decompress_dxt5(width u64, height u64, src_buf []u8, out_buf []u64) {
	C.BlockDecompressImageDXT5(width, height, src_buf.data, out_buf.data)
}

pub fn decompress_dxt5_to_rgba(width u64, height u64, src_buf []u8, mut out_buf []u8) {
	mut packed_rgba_pixels := []u64{len: int(width * height * 4)}

	decompress_dxt5(width, height, src_buf, packed_rgba_pixels)

	for j, color in packed_rgba_pixels {
		out_buf[j * 4] = u8((color >> 24) & 0xFF)
		out_buf[j * 4 + 1] = u8((color >> 16) & 0xFF)
		out_buf[j * 4 + 2] = u8((color >> 8) & 0xFF)
		out_buf[j * 4 + 3] = u8(color & 0xFF)
	}

	// Flip horizontally
	// for y in 0 .. height {
	// 	for x in 0 .. width / 2 {
	// 		for c in 0 .. 4 {
	// 			i0 := (y * width + x) * 4 + c
	// 			i1 := (y * width + width - x - 1) * 4 + c
	// 			tmp := out_buf[i0]
	// 			out_buf[i0] = out_buf[i1]
	// 			out_buf[i1] = tmp
	// 		}
	// 	}
	// }

	unsafe {
		packed_rgba_pixels.free()
	}
}
