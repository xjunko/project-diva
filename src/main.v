module main

import divagame
import divacmd

fn main() {
	$if divacmd ? {
		divacmd.run()!
	} $else {
		divagame.run()
	}
}
