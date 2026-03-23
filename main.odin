package main

import rl "vendor:raylib"
import "particles"
import "core:time"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(1280, 768, "particles")
	defer rl.CloseWindow()
	rl.SetWindowState({.WINDOW_MAXIMIZED})


	// rl.SetTargetFPS(60)
	dt: f32

	spawn := particles.SpawnCircle {
			center = {0, 0},
			radius = 10,
			arc_deg = 360,
	}

	fire_ps: particles.System
	particles.init(&fire_ps, {
		max_particles = 1000,
		spawn_rate = 250,
		lifetime = 1,
		looping = true,
		gravity = {0, -200},
		initial_speed = 10,
		size = particles.TwoValueGradient(f32) {
			start = 10,
			end = 0,
		},
		color = particles.TwoColorGradient {
			start = rl.YELLOW,
			end = rl.ORANGE,
		},
		spawn_shape = spawn,
	})
	defer particles.destroy(&fire_ps)
	
	water_ps: particles.System
	particles.init(&water_ps, {
		max_particles = 500,
		spawn_rate = 50,
		lifetime = 3,
		looping = true,
		gravity = {0, 200},
		initial_speed = 10,
		size = particles.TwoValueGradient(f32) {
			start = 5,
			end = 0,
		},
		color = rl.BLUE,
		spawn_shape = particles.SpawnCircle{
			center = {300, 300},
			radius = 10,
		},
	})
	defer particles.destroy(&water_ps)

	ambient_ps: particles.System
	particles.init(&ambient_ps, {
		max_particles = 500,
		spawn_rate = 50,
		lifetime = 3,
		looping = true,
		gravity = {0, 0},
		initial_speed = 10,
		size = particles.TwoValueGradient(f32) {
			start = 2,
			end = 0,
		},
		color = rl.WHITE,
		spawn_shape = particles.SpawnBox {
			box = rl.Rectangle {
				x = 0,
				y = 0,
				width = f32(rl.GetScreenWidth()),
				height = f32(rl.GetScreenHeight())
			}
		},
	})
	defer particles.destroy(&ambient_ps)

	burst_box := particles.SpawnBox {
		box = rl.Rectangle {
			x = 0,
			y = 0,
			width = 10,
			height = 10,
		}
	}

	burst_ps: particles.System
	particles.init(&burst_ps, {
		max_particles = 500,
		spawn_rate = 100,
		lifetime = 0.5,
		duration = 0.1,
		gravity = {0, 0},
		initial_speed = 300,
		size = particles.TwoValueGradient(f32) {
			start = 5,
			end = 0,
		},
		color = particles.TwoColorGradient {
			start = rl.WHITE,
			end = rl.RED,
		},
		spawn_shape = burst_box,
	})
	defer particles.destroy(&burst_ps)
	for !rl.WindowShouldClose() {
		dt = rl.GetFrameTime()

		start := time.now()
		particles.update(&fire_ps, dt)
		particles.update(&water_ps, dt)
		particles.update(&ambient_ps, dt)
		particles.update(&burst_ps, dt)
		dur := time.since(start)

		dur_text := rl.TextFormat("Duration: %.3f ms", time.duration_milliseconds(dur))
		spawn.center = rl.GetMousePosition()
		fire_ps.config.spawn_shape = spawn
		ambient_ps.config.spawn_shape = particles.SpawnBox {
			box = rl.Rectangle {
				x = 0,
				y = 0,
				width = f32(rl.GetScreenWidth()),
				height = f32(rl.GetScreenHeight())
			}
		}

		if rl.IsMouseButtonPressed(.LEFT) {
			burst_box.box.x = spawn.center.x
			burst_box.box.y = spawn.center.y
			burst_ps.config.spawn_shape = burst_box
			particles.play(&burst_ps)
		}

		rl.BeginDrawing()
		{
			rl.ClearBackground(rl.BLACK)
			particles.render(&ambient_ps)
			particles.render(&fire_ps)
			particles.render(&water_ps)
			particles.render(&burst_ps)
			rl.DrawFPS(10, 10)
			rl.DrawText(dur_text, 10, 30, 20, rl.SKYBLUE)
		}
		rl.EndDrawing()
	}
}
