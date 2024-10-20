module structs

import math
import crypto.aes
import crypto.cipher
import compress.gzip
import divalib.io
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

@[manualfree]
pub fn (mut ba BasicArchive) read(mut br io.BinaryReader) ! {
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

@[manualfree]
pub fn (mut ca CompressedArchive) read(mut br io.BinaryReader) ! {
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

@[manualfree]
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

@[manualfree]
pub fn (mut fa FutureArchive) read(mut br io.BinaryReader) ! {
	header_size := br.read_u32(true)

	flags := br.read_u32(true)
	is_compressed := (flags & 2) != 0 // IsCompressed
	is_encrypted := (flags & 4) != 0

	mut padding := br.read_u32(true) // Padding
	mut alignment := br.read_u32(true)
	mut is_ft := is_encrypted && (alignment & (alignment - 1)) != 0

	if is_ft {
		br.position = 0x10
		iv := br.read_n(0x10)

		// vfmt off
		mut cbc_ft := fa.create_aes_from_iv(iv)
		mut dsc := []u8{len: br.data.len}
		cbc_ft.decrypt_blocks(mut dsc, br.data)

		mut decrypted_br := io.BinaryReader.from_bytes(dsc)
		decrypted_br.position = br.position
		// vfmt on

		alignment = decrypted_br.read_u32(true)
		is_ft = decrypted_br.read_u32(true) != 0

		mut entry_count := decrypted_br.read_u32(true)

		if is_ft {
			padding = decrypted_br.read_u32(true)
		}

		for (decrypted_br.position < header_size + 0x08) {
			name := decrypted_br.read_string(.null_terminated)
			offset := decrypted_br.read_u32(true)
			compressed_size := decrypted_br.read_u32(true)
			decompressed_size := decrypted_br.read_u32(true)

			mut entry_is_encrypted := false
			mut entry_is_compressed := false

			if is_ft {
				entry_flags := decrypted_br.read_u32(true)
				entry_is_compressed = (entry_flags & 2) != 0
				entry_is_encrypted = (entry_flags & 4) != 0
			}

			mut fixed_size := u32(0)

			if is_encrypted {
				if is_compressed {
					fixed_size = (compressed_size + (alignment - 1)) & ~(alignment - 1)
				}
			} else if is_compressed {
				fixed_size = compressed_size
			} else {
				fixed_size = decompressed_size
			}

			fixed_size = math.min[u32](fixed_size, u32(decrypted_br.data.len - offset))

			$if debug {
				println('Position: ${decrypted_br.position} | Offset: ${offset} | Length: ${f32(fixed_size) / 1e+6}mb')
			}

			// Skip raw data, we'll decrypt it later
			decrypted_br.position += fixed_size

			// Decrypt entry
			// Requires original data to decrypt
			br.push_offset()
			br.position = 0x00
			mut data := []u8{}

			if is_ft {
				if entry_is_encrypted {
					br.position = offset
					entry_iv := br.read_n(16)

					mut entry_cbc := fa.create_aes_from_iv(entry_iv)

					data = []u8{len: br.data.len - br.position}
					entry_cbc.decrypt_blocks(mut data, br.data[br.position..])
				}

				if entry_is_compressed {
					data = gzip.decompress(data, verify_length: false, verify_checksum: false)!
				}
			}

			// Data is over the decompressed size
			if data.len > decompressed_size {
				unsafe {
					data = data[..decompressed_size]
				}
			}

			// Dont need the original decrypted data
			unsafe {
				decrypted_br.free()
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

			// Check for extra padding, esp with AFT files.
			// Padding check is there to silence the warning.
			entry_count--

			if (is_ft && entry_count == 0) || padding == 0xF00BA {
				break
			}
		}
	}
}
