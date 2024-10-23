module aet

import divalib.io

pub struct AetInfo {
pub:
	id    int
	name  string
	index int
}

pub struct AetSetInfo {
pub mut:
	id            int
	name          string
	filename      string
	sprite_set_id int
	aets          []AetInfo
}

pub struct AetDatabase {
mut:
	internal_br &io.BinaryReader = unsafe { nil }
pub mut:
	aet_sets []AetSetInfo
}

pub fn (mut aet_db AetDatabase) free() {
	unsafe {
		for i := 0; i < aet_db.aet_sets.len; i++ {
			for j := 0; j < aet_db.aet_sets[i].aets.len; j++ {
				aet_db.aet_sets[i].aets[j].name.free()
			}
			aet_db.aet_sets[i].name.free()
			aet_db.aet_sets[i].filename.free()
			aet_db.aet_sets[i].free()
		}
		aet_db.aet_sets.free()
		aet_db.internal_br.free()
	}
}

pub fn (mut aet_db AetDatabase) read(mut br io.BinaryReader) {
	if true {
		panic('UNTESTED!')
	}
	aet_set_count := br.read_u32(false)
	aet_sets_offset := br.read_u32(false)
	aet_count := br.read_u32(false)
	aets_offset := br.read_u32(false)

	println('[AET] Aet Set Count: ${aet_set_count} | Aet Count: ${aet_count} | Aet Sets Offset: ${aet_sets_offset} | Aets Offset: ${aets_offset}')

	aet_db.aet_sets = []AetSetInfo{len: int(aet_set_count)}

	br.read_at_offset_and(aet_sets_offset, fn [aet_set_count, mut br, mut aet_db] () {
		for i := 0; i < aet_set_count; i++ {
			aet_db.aet_sets[i].id = br.read_u32(false)
			aet_db.aet_sets[i].name = br.read_string_offset(.null_terminated)
			aet_db.aet_sets[i].filename = br.read_string_offset(.null_terminated)
			aet_db.aet_sets[i].sprite_set_id = br.read_u32(false)
		}
	})

	br.read_at_offset_and(aets_offset, fn [aet_count, mut br, mut aet_db] () {
		for i := 0; i < aet_count; i++ {
			id := br.read_u32(false)
			name := br.read_string_offset(.null_terminated)
			info := br.read_u32(false)

			{
				// TODO: Check if X format
				// If so, skip sizeof(u32)
			}
			index := u8(info & 0xFFFF)
			set_index := u8((info >> 16) & 0xFFFF)

			aet_db.aet_sets[set_index].aets << AetInfo{
				id:    int(id)
				name:  name
				index: int(index)
			}
		}
	})
}

pub fn AetDatabase.from_file(path string) !&AetDatabase {
	mut br := io.BinaryReader.from_file(path)!
	mut aet_db := &AetDatabase{
		internal_br: unsafe { br }
	}
	aet_db.read(mut br)
	return aet_db
}
