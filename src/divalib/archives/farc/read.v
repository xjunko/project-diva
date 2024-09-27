module farc

import os
import structs
import divalib.io

const basic_archive = structs.BasicArchive{}
const compressed_archive = structs.CompressedArchive{}
const future_archive = structs.FutureArchive{}

pub fn read(path string) !&structs.IArchive {
	mut raw_bytes := os.read_bytes(path)!
	mut br := io.BinaryReader.from_bytes(raw_bytes)

	header := br.read_string(.length, 4)
	match header {
		basic_archive.get_header() {
			mut ba := structs.BasicArchive{}
			ba.read(mut br)!

			return ba
		}
		compressed_archive.get_header() {
			mut ca := structs.CompressedArchive{}
			ca.read(mut br)!

			return ca
		}
		future_archive.get_header() {
			mut fa := structs.FutureArchive{}
			fa.read(mut br)!

			return fa
		}
		else {
			panic('[FARC] Unhandled archive type: ${header}')
		}
	}

	return error('[FARC] Failed to read archive')
}
