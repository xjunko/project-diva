module dsc

import math

pub fn DSCParser.diva_time_to_standard_milliseconds(pd_time_src int) f64 {
	mut pd_time := f64(pd_time_src)

	mut fractions := math.fmod(pd_time, 100000)
	pd_time -= fractions
	pd_time /= 100000

	mut seconds := math.fmod(pd_time, 60.0)
	pd_time -= seconds
	pd_time /= 60

	mut minutes := math.fmod(pd_time, 60.0)
	pd_time -= minutes
	pd_time /= 60

	// println('${minutes} ${seconds} ${fractions}')

	return (minutes * 60000) + (seconds * 1000) + (fractions / 100)
}
