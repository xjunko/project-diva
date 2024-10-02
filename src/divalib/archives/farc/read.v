module farc

import os
import structs
import divalib.io

const basic_archive = structs.BasicArchive{
	stream: unsafe { 0 }
}
const compressed_archive = structs.CompressedArchive{
	stream: unsafe { 0 }
}
const future_archive = structs.FutureArchive{
	stream: unsafe { 0 }
}

pub fn read(path string) !&structs.IArchive {
	mut raw_bytes := os.read_bytes(path)!
	mut br := io.BinaryReader.from_bytes(raw_bytes)

	header := br.read_string(.length, 4)
	match header {
		basic_archive.get_header() {
			mut ba := structs.BasicArchive{
				stream: br
			}
			ba.read(mut br)!

			return ba
		}
		compressed_archive.get_header() {
			mut ca := structs.CompressedArchive{
				stream: br
			}
			ca.read(mut br)!

			return ca
		}
		future_archive.get_header() {
			mut fa := structs.FutureArchive{
				stream: br
			}
			fa.read(mut br)!

			return fa
		}
		else {
			panic('[FARC] Unhandled archive type: ${header}')
		}
	}

	return error('[FARC] Failed to read archive')
}
