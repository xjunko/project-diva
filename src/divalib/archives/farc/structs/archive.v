module structs

import divalib.io

@[heap]
pub struct ArchiveEntry {
pub mut:
	name              string
	position          u32
	compressed_size   u32
	decompressed_size u32
	length            u32
	is_compressed     bool
	is_encrypted      bool
	is_future_tone    bool
	data              []u8
}

pub struct BasicArchive {
pub mut:
	align   u32
	entries []ArchiveEntry
	stream  &io.BinaryReader
}

pub struct CompressedArchive {
	BasicArchive
}

pub struct FutureArchive {
	BasicArchive
}

pub interface IArchive {
mut:
	align   u32
	entries []ArchiveEntry

	get_file(string) !&ArchiveEntry
	get_header() string
	free()
}
