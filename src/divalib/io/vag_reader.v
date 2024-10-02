module io

import os
import time

// vgmstream-cli se_ft_custom_module_start.vag -p | mpv -
pub struct VAGReader {
mut:
	source_file string
pub mut:
	data []u8
}

pub fn (mut vag VAGReader) read() ! {
	mut reader := os.new_process(os.find_abs_path_of_executable('vgmstream-cli')!)

	reader.set_args([
		vag.source_file,
		'-P',
	])

	reader.set_redirect_stdio()
	reader.run()

	for reader.is_pending(.stdout) {
		time.sleep(16 * time.millisecond)
	}

	// Read data
	for {
		str_data := reader.stdout_read()
		vag.data << str_data.bytes()

		if str_data.len == 0 {
			break
		}

		unsafe {
			str_data.free()
		}
	}
}

pub fn VAGReader.from_file(path string) &VAGReader {
	mut vg_reader := &VAGReader{
		source_file: path
	}
	return vg_reader
}
