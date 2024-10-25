module structs

import divalib.io

// Getter
pub fn (ba &BasicArchive) get_file(name string) !&ArchiveEntry {
	for entry in ba.entries {
		if entry.name == name {
			return &entry
		}
	}

	return error('Failed to find file: ${name}')
}

pub fn (entry &ArchiveEntry) to_vag_audio() &io.VAGReader {
	return io.VAGReader.from_bytes(entry.data)
}
