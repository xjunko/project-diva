module structs

pub struct Song {
pub mut:
	id      int
	@type   int
	bpm     int
	date    int
	reading string

	audio_path string

	japanese   SongInfo
	english    SongInfo
	performers [6]SongPerformer // there's 6 performers at most, increase this if needed
	lyrics     map[int]string
}

pub struct SongInfo {
pub mut:
	name        string
	arranger    string
	illustrator string
	lyrics      string
	music       string
}

pub struct SongPerformer {
pub mut:
	character string = 'NUL'
	role      string = 'NUL'
}
