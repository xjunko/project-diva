module bcdec

import arrays

#flag -I @VMODROOT/c
#define BCDEC_IMPLEMENTATION 1
#include "wrap.c"

pub fn C.jnko_dxt1(&u8, int, int) &u8
pub fn C.jnko_dxt3(&u8, int, int) &u8
pub fn C.jnko_dxt5(&u8, int, int) &u8

pub fn C.jnko_ati1(&u8, int, int) &u8
pub fn C.jnko_ati2(&u8, int, int) &u8

pub fn get_dxt1(src []u8, width int, height int) []u8 {
	mut c_array := C.jnko_dxt1(src.data, width, height)
	return unsafe { arrays.carray_to_varray[u8](c_array, (width * height * 4)) }
}

pub fn get_dxt3(src []u8, width int, height int) []u8 {
	mut c_array := C.jnko_dxt3(src.data, width, height)
	return unsafe { arrays.carray_to_varray[u8](c_array, (width * height * 4)) }
}

pub fn get_dxt5(src []u8, width int, height int) []u8 {
	mut c_array := C.jnko_dxt5(src.data, width, height)
	return unsafe { arrays.carray_to_varray[u8](c_array, (width * height * 4)) }
}

pub fn get_ati1(src []u8, width int, height int) []u8 {
	mut c_array := C.jnko_ati1(src.data, width, height)
	return unsafe { arrays.carray_to_varray[u8](c_array, (width * height)) }
}

pub fn get_ati2(src []u8, width int, height int) []u8 {
	mut c_array := C.jnko_ati2(src.data, width, height)
	return unsafe { arrays.carray_to_varray[u8](c_array, (width * height * 2)) }
}
