package particles

import "core:math/rand"
import "core:math"
import rl "vendor:raylib"

Particle :: struct {
	position: [2]f32,
	velocity: [2]f32,
	life: f32,
	alive: bool,
}

SpawnCircle :: struct {
	center: [2]f32,
	radius: f32,
	arc_deg: f32,
}

SpawnBox :: struct {
	box: rl.Rectangle,
}

SpawnShape :: union {
	SpawnCircle,
	SpawnBox,
}

Config :: struct {
	max_particles: int,
	spawn_rate: int,
	spawn_shape: SpawnShape,
	gravity: [2]f32,
	lifetime: f32,
	duration: f32,
	initial_speed: f32,
	color: ColorValue,
	size: NumberValue,
	looping: bool,
}

System :: struct {
	particles: []Particle,
	config: Config,
	count: int,
	last_idx: int,
	time_to_next: f32,
	duration_remaining: f32,
	playing: bool,
}

init :: proc(ps: ^System, conf: Config) {
	ps.config = conf
	ps.particles = make([]Particle, ps.config.max_particles)
	ps.time_to_next = 1 / f32(ps.config.spawn_rate)
	ps.playing = true
	ps.duration_remaining = ps.config.duration
}

destroy :: proc(ps: ^System) {
	delete(ps.particles)
}

update :: proc(ps: ^System, dt: f32) {
	if ps.playing {
		if !ps.config.looping {
			ps.duration_remaining -= dt
			if ps.duration_remaining <= 0 {
				ps.playing = false
			}
		}
		if ps.count < ps.config.max_particles {
			ps.time_to_next -= dt
			for ps.time_to_next <= 0 {
				if !spawn(ps) {
					break
				}
				ps.time_to_next += 1 / f32(ps.config.spawn_rate)
			}
		}

	}
	for &p in ps.particles {
		if !p.alive {
			continue
		}
		p.life -= dt
		p.position += p.velocity * dt
		if p.life <= 0 {
			p.alive = false
			ps.count -= 1
		}
		p.velocity += ps.config.gravity * dt
	}
}

render :: proc(ps: ^System) {
	for p in ps.particles {
		if !p.alive {
			continue
		}

		col: rl.Color
		switch cv in ps.config.color {
		case rl.Color:
			col = cv
		case TwoColorGradient:
			t := p.life / ps.config.lifetime
			col = rl.ColorLerp(cv.end, cv.start, t)
		}

		s: f32
		switch nv in ps.config.size {
		case f32:
			s = nv
		case TwoValueGradient(f32):
			t := p.life / ps.config.lifetime
			s = math.lerp(nv.end, nv.start, t)
		}

		rec := rl.Rectangle {
			x = -s,
			y = -s,
			width = s * 2,
			height = s * 2,
		}
		rl.DrawRectanglePro(rec, -p.position, 0, col)
	}
}

spawn :: proc(ps: ^System) -> bool {
	if ps.count >= ps.config.max_particles {
		return false
	}
	ps.count += 1
	part := Particle {
		alive = true,
		life = ps.config.lifetime,
	}
	switch sp in ps.config.spawn_shape {
	case SpawnCircle:
		ang := rand.float32() * math.RAD_PER_DEG * sp.arc_deg
		rad := math.lerp(f32(0), sp.radius, rand.float32())
		vec := [2]f32{
			math.cos(ang), math.sin(ang)
		}
		part.position = sp.center + rad * vec
		part.velocity = vec * ps.config.initial_speed
	case SpawnBox:
		x := math.lerp(f32(0), sp.box.width, rand.float32())
		y := math.lerp(f32(0), sp.box.height, rand.float32())
		part.position = {sp.box.x + x, sp.box.y + y}

		ang := rand.float32() * math.PI * 2
		vec := [2]f32{
			math.cos(ang), math.sin(ang)
		}
		part.velocity = vec * ps.config.initial_speed
	}
	ps.particles[ps.last_idx] = part
	ps.last_idx = (ps.last_idx + 1) % ps.config.max_particles

	return true
}

play :: proc(ps: ^System) {
	ps.playing = true
	ps.duration_remaining = ps.config.duration
}

pause :: proc(ps: ^System) {
	ps.playing = false
}
