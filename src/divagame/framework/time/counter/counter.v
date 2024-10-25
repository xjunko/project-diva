module counter

import math
import time as timelib

pub struct TimeCounter {
mut:
	start_time f64
	last_time  f64
	offset     f64
pub mut:
	delta f64
	time  f64
	fps   f64
	speed f64 = 1.0
	//
	stop bool
	//
	average f64
}

pub fn (mut t TimeCounter) stop() {
	t.stop = true
}

@[args; params]
pub struct ResetArgs {
pub:
	offset f64
}

pub fn (mut t TimeCounter) reset(arg ResetArgs) {
	t.offset = arg.offset
	t.last_time = timelib.ticks()
	t.start_time = t.last_time
	t.time = 0
	t.delta = 0
	t.fps = 0
}

pub fn (mut t TimeCounter) tick() f64 {
	now := timelib.ticks()

	t.delta = now - t.last_time
	t.time = ((now - t.start_time) * t.speed) - t.offset
	t.last_time = now

	t.fps = 1000.0 / t.delta

	return t.delta
}

pub fn (mut t TimeCounter) set_speed(s f64) {
	t.speed = s
}

pub fn (mut t TimeCounter) tick_average_fps() {
	delta := t.tick()

	if t.average == 0.0 {
		t.average = delta
	}

	rate := f64(1.0 - math.pow(0.4, delta / 100.0))
	t.average = t.average + (delta - t.average) * rate
}

pub fn (t &TimeCounter) get_average_fps() f64 {
	return 1000.0 / t.average
}
