package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

MAX_BALLS :: 500
THRESHOLD :: 70
THRESHOLD_SQUARED :: THRESHOLD * THRESHOLD

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
            radius = 4,
            color = { 80, 50, 175, 255 },
        }
    }
}

update_balls :: proc(dt: f32) {
    for &ball in g_mem.balls {
        ball.position.x += ball.velocity.x * dt
        ball.position.y += ball.velocity.y * dt
        check_bounds_ball(&ball)
    }
}

render_balls :: proc() {
    for ball in g_mem.balls {
        cell_width := g_mem.window_width / 16
        cell_height := g_mem.window_height / 16
        rect := rl.Rectangle {
            x = f32(ball.grid_x) * cell_width,
            y = f32(ball.grid_y) * cell_height,
            width = cell_width,
            height = cell_height,
        }

        rl.DrawCircleV(ball.position, ball.radius, ball.color)
    }

    for i := 0; i < len(g_mem.balls); i += 1 {
        for j := i + 1; j < len(g_mem.balls); j += 1 {
            b1 := g_mem.balls[i]
            b2 := g_mem.balls[j]
            dx := b2.position.x - b1.position.x
            dy := b2.position.y - b1.position.y
            distance_squared := dx * dx + dy * dy
            if distance_squared <= THRESHOLD_SQUARED {
                alpha := ((THRESHOLD_SQUARED - distance_squared) / THRESHOLD_SQUARED) * 255
                rl.DrawLineEx(b1.position, b2.position, 1.5, { 80, 50, 175, u8(alpha) })
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
