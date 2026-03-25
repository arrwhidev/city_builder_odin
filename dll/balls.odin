package game

import "core:math/rand"
import rl "vendor:raylib"

MAX_BALLS :: 100
BALL_COLOUR :: rl.BLACK

Ball :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius:   f32,
    color:    rl.Color,
}

// Balls allocated upfront as ring buffer.
BallData :: struct {
    balls:    []Ball,
    next_idx: int,
}

get_balls_data :: proc() -> ^BallData {
    return &g_mem.ball_data
}

balls_init :: proc() -> BallData {
    return BallData {
        balls    = make([]Ball, MAX_BALLS),
        next_idx = 0,
    }
}

ball_spawn :: proc() {
    data := get_balls_data()

    data.balls[data.next_idx] = Ball{
        position = {
            rand.float32_range(0, g_mem.window_width),
            rand.float32_range(0, g_mem.window_height),
        },
        velocity = {
            rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
            rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
        },
        radius = 4,
        color = BALL_COLOUR,
    }

    data.next_idx = (data.next_idx + 1) % MAX_BALLS
}

balls_update :: proc(dt: f32) {
    data := get_balls_data()

    if(rl.IsKeyPressed(rl.KeyboardKey.B)) {
        ball_spawn()
    }

    speed_mult := f32(2.4)
    for &ball in data.balls {
        ball.position.x += ball.velocity.x * dt * speed_mult
        ball.position.y += ball.velocity.y * dt * speed_mult
    }
}

balls_render :: proc() {
    data := get_balls_data()

    for &ball in data.balls {
        rl.DrawCircleV(ball.position, ball.radius, ball.color)
    }
}
