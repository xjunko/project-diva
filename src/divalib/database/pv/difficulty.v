module pv

pub struct Difficulty {
pub mut:
	name   string // easy, normal, hard, extreme
	script DifficultyScriptInfo
}

pub struct DifficultyScriptInfo {
pub mut:
	path       string
	format     string
	version    int
	attributes map[string]string
}
