module io

import os
import encoding.binary

pub struct BinaryReader {
pub mut:
	data     []u8
	position int
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
