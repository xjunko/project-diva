module dxt

pub fn test_pack_unpack() {
	in_r, in_g, in_b, in_a := u8(1), u8(2), u8(3), u8(4)
	packed := C.PackRGBA(in_r, in_g, in_b, in_a)
	out_r, out_g, out_b, out_a := u8(1), u8(2), u8(3), u8(4)
	C.UnpackRGBA(packed, &out_r, &out_g, &out_b, &out_a)
	assert in_r == out_r && in_g == out_g && in_b == out_b && in_a == out_a
}
