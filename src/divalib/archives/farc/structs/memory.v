module structs

pub fn (entry &ArchiveEntry) free() {
	unsafe {
		entry.data.free()
	}
}

pub fn (ba &BasicArchive) free() {
	// Fields doesn't need to be freed
	// Only the BinaryReader
	unsafe {
		ba.stream.free()
	}
}
