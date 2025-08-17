package game

import "core:math/rand"
import rl "vendor:raylib"

MAX_BALLS :: 30

Ball :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32,
    color: rl.Color,
}

init_balls :: proc(mem: ^GameMemory) {
    for i in 0..<MAX_BALLS {
        mem.balls[i] = Ball {
            position = { 
                rand.float32_range(0, f32(mem.window_width)),
                rand.float32_range(0, f32(mem.window_height)),
            },
            velocity = { 
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1), 
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
            },
            radius = rand.float32_range(4, 10),
            color = rl.BLUE,
        }
    }
}

update_balls :: proc(dt: f32) {
    for &ball in g_mem.balls {
        ball.position.x += ball.velocity.x * dt
        ball.position.y += ball.velocity.y * dt

        if ball.position.x < 0 || ball.position.x > f32(g_mem.window_width) {
            ball.velocity.x *= -1
        }
        if ball.position.y < 0 || ball.position.y > f32(g_mem.window_height) {
            ball.velocity.y *= -1
        }
    }

    for i in 0..<MAX_BALLS {
        ball_i := &g_mem.balls[i]
        for j in i+1..<MAX_BALLS {
            ball_j := &g_mem.balls[j]
            collision := rl.CheckCollisionCircles(
                ball_i.position, ball_i.radius,
                ball_j.position, ball_j.radius,
            )
            if collision {
                ball_i.velocity.x *= -1
                ball_i.velocity.y *= -1
                ball_j.velocity.x *= -1
                ball_j.velocity.y *= -1
            }
        }
    }
}

render_balls :: proc() {
    for ball in g_mem.balls {
        rl.DrawRectangle(i32(ball.position.x), i32(ball.position.y), 10, 10, ball.color)
    }
}
