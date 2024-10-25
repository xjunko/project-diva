module main

// import divagame
import divacmd
import divaplayer

fn main() {
	$if divacmd ? {
		divacmd.run()!
	} $else $if divaplayer ? {
		divaplayer.run()
	} $else {
		// divagame.run()
	}
}
