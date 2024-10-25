module divaplayer

import os
import time
import gg
import gx
import sync
import bass
import divalib.scripts.dsc
import divalib.scripts.dsc.opcodes
import divalib.database.pv
import divagame.framework.time.fps
import divagame.framework.time.counter

const diva_root = '/mnt/Second/Games/PDAFT/SBZV_7.01/'

@[heap]
pub struct Application {
mut:
	ctx &gg.Context = unsafe { nil }

	pvs pv.DBParser

	current_pv     pv.DBEntry
	current_script dsc.DSCParser
	current_audio  &bass.Track = unsafe { nil }

	current_time          f32
	current_lyric         string
	current_pv_performers string

	current_lock &sync.Mutex = sync.new_mutex()
}

pub fn (mut application Application) init(_ voidptr) {
	bass.start()

	// PV
	application.pvs = pv.DBParser.from_pvdb(os.join_path(diva_root, 'rom/pv_db.txt')) or {
		panic(err)
	}
	application.current_pv = application.pvs.entries[261]
	application.current_pv_performers = application.current_pv.song.performers.filter(it.character != 'NUL').map(it.character).join(', ')
	application.current_script = dsc.DSCParser.from_file(os.join_path(diva_root, application.current_pv.difficulties['hard_0'].script.path)) or {
		panic(err)
	}

	// Current PV setup
	current_pv_audio := os.join_path(diva_root, application.current_pv.song.audio_path)
	application.current_audio = bass.new_track(current_pv_audio)
	application.current_audio.set_volume(0.5)

	// Multi-thread setup
	go fn [mut application] () {
		mut limiter := fps.Limiter.create(120)
		mut thread_time := counter.TimeCounter{}

		thread_time.reset(offset: 1000)

		for {
			thread_time.tick()
			application.update(f32(thread_time.time))
			limiter.sync()
		}
	}()

	go fn [mut application] () {
		mut limiter := fps.Limiter.create(60)
		mut index := 0

		mut hit := bass.new_sample('${@VMODROOT}/assets/sfx/hit.wav')
		hit.set_volume(0.5)

		for {
			for i := index; i < application.current_script.commands.len; i++ {
				if application.current_time >= application.current_script.commands[i].end_time {
					index = i + 1
					match application.current_script.commands[i].action {
						'LYRIC' {
							application.current_lock.lock()
							application.current_lyric = application.current_pv.song.lyrics[application.current_script.commands[i].values[0]]
							application.current_lock.unlock()
						}
						'TARGET' {
							hit.play()
							continue
						}
						'MUSIC_PLAY' {
							println('[DivaPlayer] Playing music!')
							application.current_audio.play()
							continue
						}
						else {}
					}
				}
			}

			limiter.sync()
		}
	}()
}

pub fn (mut application Application) pv_info() {
	// Metadata
	application.ctx.draw_rect_filled(0, 0, 200, 75, gx.black)
	application.ctx.draw_text(8, 8, 'Title: ${application.current_pv.song.japanese.name}',
		color: gx.white
	)
	application.ctx.draw_text(8, 24, 'Performers: ${application.current_pv_performers}',
		color: gx.white
	)
	application.ctx.draw_text(8, 42, 'Time: ${application.current_time:.2f}',
		color: gx.white
	)

	// Lyric
	application.current_lock.lock()
	if application.current_lyric.len != 0 {
		application.ctx.draw_text(1280 / 2, 720 - 100, '${application.current_lyric}',
			color: gx.white
			align: .center
			bold:  true
			size:  24
		)
	}
	application.current_lock.unlock()
}

pub fn (mut application Application) update(time_ms f32) {
	application.current_time = time_ms
}

pub fn (mut application Application) frame(_ voidptr) {
	application.ctx.begin()

	application.pv_info()

	application.ctx.end()
}

pub fn Application.create() &Application {
	mut app := &Application{}
	app.ctx = gg.new_context(
		width:     1280
		height:    720
		user_data: app
		init_fn:   app.init
		frame_fn:  app.frame
		bg_color:  gx.gray
		font_path: 'assets/dev/font/DFPOPMix-W5-WIN-RKSJ-H-01.ttf'
	)

	return app
}

pub fn run() {
	mut app := Application.create()
	app.ctx.run()
}
