module structs

import math
import crypto.aes
import crypto.cipher
import compress.gzip
import divalib.farc.utils
import os

// Headers
pub fn BasicArchive.get_header() string {
	return 'FArc'
}

pub fn (ba BasicArchive) get_header() string {
	return BasicArchive.get_header()
}

pub fn CompressedArchive.get_header() string {
	return 'FArC'
}

pub fn (ca CompressedArchive) get_header() string {
	return CompressedArchive.get_header()
}

pub fn FutureArchive.get_header() string {
	return 'FARC'
}

pub fn (fa FutureArchive) get_header() string {
	return FutureArchive.get_header()
}

// Extract
pub fn (mut ba BasicArchive) read(mut br utils.BinaryReader) ! {
	header_size := br.read_u32(true)
	alignment := br.read_u32(true)

	for (br.position < header_size + 0x08) {
		name := br.read_string(.null_terminated)
		offset := br.read_u32(true)
		size := br.read_u32(true)

		$if debug {
			println('[BasicArchive]: Entry | Name=${name} | Offset=${offset} | Size=${size}')
		}

		ba.entries << ArchiveEntry{
			name:              name
			position:          offset
			compressed_size:   size
			decompressed_size: size
			length:            size
			is_compressed:     false
			data:              br.data[offset..offset + size]
		}
	}

	ba.align = alignment
}

pub fn (mut ca CompressedArchive) read(mut br utils.BinaryReader) ! {
	header_size := br.read_u32(true)
	alignment := br.read_u32(true)

	for (br.position < header_size + 0x08) {
		name := br.read_string(.null_terminated)
		offset := br.read_u32(true)

		compressed_size := br.read_u32(true)
		decompressed_size := br.read_u32(true)
		fixed_size := math.min[u32](compressed_size, u32(br.data.len - offset))

		compressed_data := br.data[offset..offset + fixed_size]
		decompressed_data := gzip.decompress(compressed_data)!

		$if debug {
			println('[CompressedArchive]: Entry | Name=${name} | Offset=${offset} | Compressed=${compressed_size} | Decompressed=${decompressed_size} | FixedSize=${fixed_size}')
		}

		ca.entries << ArchiveEntry{
			name:              name
			position:          offset
			compressed_size:   compressed_size
			decompressed_size: decompressed_size
			length:            fixed_size
			is_compressed:     compressed_size != decompressed_size
			data:              decompressed_data
		}
	}

	ca.align = alignment
}

pub interface FutureToneDecryptor {
mut:
	free()
	decrypt_blocks(mut dst []u8, src []u8)
}

pub fn (mut fa FutureArchive) create_aes_from_iv(iv []u8) FutureToneDecryptor {
	// vfmt off
	mut aes_ft := aes.new_cipher([
		u8(0x13), 0x72, 0xD5, 0x7B, 
		0x6E, 0x9E, 0x31, 0xEB, 
		0xA2, 0x39, 0xB8, 0x3C, 
		0x15, 0x57, 0xC6, 0xBB
	])
	// vfmt on

	mut cbc_ft := cipher.new_cbc(aes_ft, iv)
	return cbc_ft
}

pub fn (mut fa FutureArchive) read(mut br utils.BinaryReader) ! {
	header_size := br.read_u32(true)

	flags := br.read_u32(true)
	is_compressed := (flags & 2) != 0
	is_encrypted := (flags & 4) != 0

	mut padding := br.read_u32(true)
	mut alignment := br.read_u32(true)
	mut is_ft := is_encrypted && (alignment & (alignment - 1)) != 0

	mut original_data := br.data.clone()

	if is_ft {
		br.position = 0x10
		iv := br.read_n(0x10)

		// vfmt off
		mut cbc_ft := fa.create_aes_from_iv(iv)
		mut dsc := []u8{len: br.data.len}
		cbc_ft.decrypt_blocks(mut dsc, br.data)
		br.data = dsc
		// vfmt on

		alignment = br.read_u32(true)
		is_ft = br.read_u32(true) != 0

		entry_count := br.read_u32(true)

		if is_ft {
			padding = br.read_u32(true)
		}

		println('Entry Count: ${entry_count}')
		println('Padding: ${padding}')
		println('Alignment: ${alignment}')
		println('Is FT: ${is_ft}')
		println('IsCompressed: ${is_compressed}')
		println('IsEncrypted: ${is_encrypted}')

		for (br.position < header_size + 0x08) {
			name := br.read_string(.null_terminated)
			offset := br.read_u32(true)
			compressed_size := br.read_u32(true)
			decompressed_size := br.read_u32(true)

			mut entry_is_encrypted := false
			mut entry_is_compressed := false

			if is_ft {
				entry_flags := br.read_u32(true)
				entry_is_compressed = (entry_flags & 2) != 0
				entry_is_encrypted = (entry_flags & 4) != 0
			}

			mut fixed_size := u32(0)

			if entry_is_encrypted {
				if entry_is_compressed {
					fixed_size = (compressed_size + (alignment - 1)) & ~(alignment - 1)
				}
			} else if entry_is_compressed {
				fixed_size = compressed_size
			} else {
				fixed_size = decompressed_size
			}

			fixed_size = math.min[u32](fixed_size, u32(br.data.len - offset))

			$if debug {
				println('Position: ${br.position} | Offset: ${offset} | Length: ${f32(fixed_size) / 1e+6}mb')
			}

			// Skip raw data, we'll decrypt it later
			br.position += fixed_size

			// Decrypt entry
			// Requires original data to decrypt
			mut binary_file_reader := utils.BinaryReader.from_bytes(original_data)
			mut data := []u8{}

			if is_ft {
				if entry_is_encrypted {
					binary_file_reader.position = offset
					entry_iv := binary_file_reader.read_n(16)

					mut entry_cbc := fa.create_aes_from_iv(entry_iv)

					data = []u8{len: binary_file_reader.data.len - binary_file_reader.position}
					entry_cbc.decrypt_blocks(mut data, binary_file_reader.data[binary_file_reader.position..])
				}

				if entry_is_compressed {
					data = gzip.decompress(data, verify_length: false, verify_checksum: false)!
				}
			}

			$if debug {
				println('[FutureArchive]: Entry | Name=${name} | Offset=${offset} | Compressed=${f32(compressed_size) / 1e+6}mb | Decompressed=${f32(decompressed_size) / 1e+6}mb | FixedSize=${f32(fixed_size) / 1e+6}mb')
			}

			fa.entries << ArchiveEntry{
				name:              name
				position:          offset
				compressed_size:   compressed_size
				decompressed_size: decompressed_size
				length:            fixed_size
				is_compressed:     decompressed_size != fixed_size
				is_encrypted:      entry_is_encrypted
				is_future_tone:    is_ft
				data:              data
			}
		}
	}
}
