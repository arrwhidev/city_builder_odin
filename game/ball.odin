package game

import "core:math/rand"
import rl "vendor:raylib"

MAX_BALLS :: 1200
BALL_COLOUR :: rl.Color{ 30, 75, 170, 255 }

Ball :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32,
    color: rl.Color,
    grid_x: int,
    grid_y: int,
}

init_balls :: proc(mem: ^GameMemory) {
    for i in 0..<MAX_BALLS {
        mem.balls[i] = Ball {
            position = {
                rand.float32_range(0, mem.window_width),
                rand.float32_range(0, mem.window_height),
            },
            velocity = {
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
            },
            radius = mem.ui_params.ball_radius,
            color = BALL_COLOUR,
        }
    }
}

update_balls :: proc(dt: f32) {
    speed_mult := g_mem.ui_params.speed_multiplier
    for &ball in g_mem.balls {
        ball.position.x += ball.velocity.x * dt * speed_mult
        ball.position.y += ball.velocity.y * dt * speed_mult
        ball.radius = g_mem.ui_params.ball_radius
        check_bounds_ball(&ball)
    }
}

render_balls :: proc() {
    for ball in g_mem.balls {
        rl.DrawCircleV(ball.position, ball.radius, ball.color)
    }

    threshold_sq := g_mem.ui_params.threshold * g_mem.ui_params.threshold
    line_width := g_mem.ui_params.line_width

    for i := 0; i < len(g_mem.balls); i += 1 {
        for j := i + 1; j < len(g_mem.balls); j += 1 {
            b1 := g_mem.balls[i]
            b2 := g_mem.balls[j]
            dx := b2.position.x - b1.position.x
            dy := b2.position.y - b1.position.y
            distance_squared := dx * dx + dy * dy
            if distance_squared <= threshold_sq {
                alpha := ((threshold_sq - distance_squared) / threshold_sq) * 255
                c := rl.Color{ BALL_COLOUR[0], BALL_COLOUR[1], BALL_COLOUR[2], u8(alpha) }
                rl.DrawLineEx(b1.position, b2.position, line_width, c)
            }
        }
    }
}

check_bounds_ball :: proc(ball: ^Ball) {
    if ball.position.x - ball.radius <= 0 {
        ball.position.x = ball.radius
        ball.velocity.x *= -1
    } else if ball.position.x + ball.radius > g_mem.window_width {
        ball.position.x = g_mem.window_width - ball.radius
        ball.velocity.x *= -1
    }

    if ball.position.y - ball.radius <= 0 {
        ball.position.y = ball.radius
        ball.velocity.y *= -1
    } else if ball.position.y + ball.radius > g_mem.window_height {
        ball.position.y = g_mem.window_height - ball.radius
        ball.velocity.y *= -1
    }
}
