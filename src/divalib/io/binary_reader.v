module io

import os
import math.bits
import encoding.binary

pub struct BinaryReader {
mut:
	offsets []int
pub mut:
	data     []u8
	position int
}

// Free
pub fn (br &BinaryReader) free() {
	unsafe {
		br.offsets.free()
		br.data.free()
	}
}

// Offset
pub fn (mut br BinaryReader) get_base_offset() int {
	if br.offsets.len == 0 {
		return 0
	}

	return br.offsets[br.offsets.len - 1]
}

// Callbacks
pub type BinaryReaderCallback = fn ()

pub fn (mut br BinaryReader) read_offset_and(callback &BinaryReaderCallback) {
	offset := br.read_u32(false)

	if offset == 0 {
		return
	}

	mut current := br.position
	br.to(br.get_base_offset() + offset)
	callback()
	br.to(current)
}

// Moving
pub fn (mut br BinaryReader) seek(amount int) {
	br.position += amount
}

pub fn (mut br BinaryReader) to(position int) {
	br.position = position
}

pub fn (mut br BinaryReader) push_offset() {
	br.offsets << br.position
}

pub fn (mut br BinaryReader) pop_offset() {
	if br.offsets.len > 0 {
		br.position = br.offsets.pop()
	}
}

// Reading Operations
pub fn (mut br BinaryReader) read_n(amount int) []u8 {
	if br.position + amount > br.data.len {
		println('[BinaryReader]: read_n: Out of bounds | ${br.position + amount} > ${br.data.len}')
		return []
	}

	mut data := br.data[br.position..br.position + amount]
	br.position += amount

	return data
}

pub fn (mut br BinaryReader) read_byte() u8 {
	return br.read_n(1)[0]
}

pub enum BinaryReaderStringMethod {
	null_terminated
	length
}

pub fn (mut br BinaryReader) read_string_offset(method BinaryReaderStringMethod, optional_length ...int) string {
	offset := br.read_u32(false)
	mut current := br.position
	br.position = offset
	mut data := br.read_string(method, ...optional_length)
	br.position = current

	return data
}

pub fn (mut br BinaryReader) read_string(method BinaryReaderStringMethod, optional_length ...int) string {
	match method {
		.null_terminated {
			mut data := []u8{}

			for {
				current_byte := br.read_byte()
				if current_byte == 0 {
					break
				} else {
					data << current_byte
				}
			}

			return data.bytestr()
		}
		.length {
			if optional_length.len == 0 {
				return ''
			}

			if str_length := optional_length[0] {
				if str_length == 0 {
					return ''
				}

				return br.read_n(str_length).bytestr()
			}
		}
	}

	return ''
}

pub fn (mut br BinaryReader) read_u8() u8 {
	return br.read_byte()
}

pub fn (mut br BinaryReader) read_u16(big_endian bool) u16 {
	mut data := br.read_n(2)

	if big_endian {
		return binary.big_endian_u16(data)
	}
	return binary.little_endian_u16(data)
}

pub fn (mut br BinaryReader) read_u32(big_endian bool) u32 {
	mut data := br.read_n(4)

	if big_endian {
		return binary.big_endian_u32(data)
	}
	return binary.little_endian_u32(data)
}

pub fn (mut br BinaryReader) read_u64(big_endian bool) u64 {
	mut data := br.read_n(8)

	if big_endian {
		return binary.big_endian_u64(data)
	}
	return binary.little_endian_u64(data)
}

// Unique types
pub fn (mut br BinaryReader) read_single(big_endian bool) f32 {
	return bits.f32_from_bits(br.read_u32(big_endian))
}

pub fn (mut br BinaryReader) read_singles(big_endian bool, amount int) []f32 {
	mut data := []f32{}

	for i := 0; i < amount; i++ {
		data << br.read_single(big_endian)
	}

	return data
}

// Factory
pub fn BinaryReader.from_bytes(data []u8) &BinaryReader {
	mut br := &BinaryReader{}

	br.data = data
	br.position = 0

	return br
}

pub fn BinaryReader.from_file(path string) !&BinaryReader {
	raw_bytes := os.read_bytes(path)!
	return BinaryReader.from_bytes(raw_bytes)
}
