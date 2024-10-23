module pv

import os

pub struct DBParser {
pub mut:
	entries map[int]DBEntry
}

pub struct DBEntry {
pub mut:
	song         Song
	difficulties map[string]Difficulty
}

pub fn DBParser.from_pvdb(path string) !DBParser {
	mut db := DBParser{}

	mut lines := os.read_lines(path)!

	mut current_song := Song{}
	mut current_difficulties := map[string]Difficulty{}

	mut last_id := -1

	for line in lines {
		if line.trim_space().len == 0 || line.starts_with('#') || !line.starts_with('pv') {
			continue
		}

		prefix := line.split_nth('.', 2)
		suffix := prefix[1].split('=')

		song_id := prefix[0].split_nth('_', 2)[1].int()
		key := suffix[0]
		value := suffix[1]

		if song_id != last_id && last_id != -1 {
			current_song.id = last_id
			db.entries[current_song.id] = DBEntry{
				song:         current_song
				difficulties: current_difficulties
			}

			println('[PVDB] [${current_song.id}] - ${current_song.japanese.name}')

			current_song = Song{}
			current_difficulties = map[string]Difficulty{}
		}

		last_id = song_id

		mut unhandled := false

		// Normal Attribute
		match key {
			'bpm' {
				current_song.bpm = value.int()
			}
			'date' {
				current_song.date = value.int()
			}
			'song_name_reading' {
				current_song.reading = value
			}
			'song_file_name' {
				current_song.audio_path = value
			}
			// Localization
			'song_name' {
				current_song.japanese.name = value
			}
			'songinfo.arranger' {
				current_song.japanese.arranger = value
			}
			'songinfo.illustrator' {
				current_song.japanese.illustrator = value
			}
			'songinfo.lyrics' {
				current_song.japanese.lyrics = value
			}
			'songinfo.music' {
				current_song.japanese.music = value
			}
			// English
			'song_name_en' {
				current_song.english.name = value
			}
			'songinfo_en.arranger' {
				current_song.english.arranger = value
			}
			'songinfo_en.illustrator' {
				current_song.english.illustrator = value
			}
			'songinfo_en.lyrics' {
				current_song.english.lyrics = value
			}
			'songinfo_en.music' {
				current_song.english.music = value
			}
			else {
				unhandled = true
			}
		}

		// Functional Attribute
		if key.starts_with('lyric.') {
			lyric_index := key.split_n('.', 2)[1].int()
			current_song.lyrics[lyric_index] = value
		}
		if key.starts_with('performer') {
			items := key.split_n('.', 3)

			if items.len < 3 {
				continue
			}

			performer_index := items[1].int()

			match items[2] {
				'chara' {
					current_song.performers[performer_index].character = value
				}
				'type' {
					current_song.performers[performer_index].role = value
				}
				else {}
			}
		}
		if key.starts_with('difficulty') {
			items := key.split_n('.', 4)

			if items.len < 4 {
				continue
			}

			difficulty_index := items[1] + '_' + items[2]

			if difficulty_index !in current_difficulties {
				current_difficulties[difficulty_index] = Difficulty{}
			}

			match items[3] {
				'script_file_name' {
					current_difficulties[difficulty_index].script.path = value
				}
				'script_format' {
					current_difficulties[difficulty_index].script.format = value
				}
				'version' {
					current_difficulties[difficulty_index].script.version = value.int()
				}
				else {}
			}

			if items[3].starts_with('attribute') {
				attribute_key := items[3].split_nth('.', 2)[1]
				current_difficulties[difficulty_index].script.attributes[attribute_key] = value
			}
		}
	}

	return db
}
