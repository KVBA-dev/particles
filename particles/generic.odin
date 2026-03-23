package particles

import rl "vendor:raylib"

TwoValueGradient :: struct($T: typeid) {
	start: T,
	end: T,
}

ColorValue :: union {
	rl.Color,
	TwoValueGradient(rl.Color),
}

NumberValue :: union {
	f32,
	TwoValueGradient(f32),
}

TwoColorGradient :: #type TwoValueGradient(rl.Color)
