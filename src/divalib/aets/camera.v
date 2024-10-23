module aets

import divalib.io

pub struct Camera {
pub mut:
	eye_x       FCurve
	eye_y       FCurve
	eye_z       FCurve
	position_x  FCurve
	position_y  FCurve
	position_z  FCurve
	direction_x FCurve
	direction_y FCurve
	direction_z FCurve
	rotation_x  FCurve
	rotation_y  FCurve
	rotation_z  FCurve
	zoom        FCurve
}

pub fn (mut camera Camera) read(mut br io.BinaryReader) {
	println('1')
	camera.eye_x.read(mut br)
	println('2')
	camera.eye_y.read(mut br)
	println('3')
	camera.eye_z.read(mut br)
	camera.position_x.read(mut br)
	camera.position_y.read(mut br)
	camera.position_z.read(mut br)
	camera.direction_x.read(mut br)
	camera.direction_y.read(mut br)
	camera.direction_z.read(mut br)
	camera.rotation_x.read(mut br)
	camera.rotation_y.read(mut br)
	camera.rotation_z.read(mut br)
	camera.zoom.read(mut br)
}
