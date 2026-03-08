package game

import "core:math/rand"
import mu "vendor:microui"
import rl "vendor:raylib"

MAX_BALLS :: 1200
BALL_COLOUR :: rl.Color{30, 75, 170, 255}

Ball :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius:   f32,
    color:    rl.Color,
}

UIParams :: struct {
    threshold:        f32,
    ball_radius:      f32,
    speed_multiplier: f32,
    line_width:       f32,
    show_ui:          bool,
}

BallsLevelData :: struct {
    balls:     [MAX_BALLS]Ball,
    ui_params: UIParams,
    camera:    rl.Camera2D,
    mu_ctx:    mu.Context,
}

get_balls_data :: proc() -> ^BallsLevelData {
    return cast(^BallsLevelData)g_mem.level_data
}

balls_init :: proc() -> rawptr {
    data := new(BallsLevelData, level_allocator())

    init_ui(&data.mu_ctx)

    data.ui_params = UIParams{
        threshold        = 35.0,
        ball_radius      = 2.0,
        speed_multiplier = 0.5,
        line_width       = 1.0,
        show_ui          = true,
    }

    data.camera = rl.Camera2D{
        target   = {0, 0},
        offset   = {0, 0},
        rotation = 0,
        zoom     = 1,
    }

    for i in 0 ..< MAX_BALLS {
        data.balls[i] = Ball{
            position = {
                rand.float32_range(0, g_mem.window_width),
                rand.float32_range(0, g_mem.window_height),
            },
            velocity = {
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
                rand.float32_range(30, 120) * (rand.float32() > 0.5 ? 1 : -1),
            },
            radius = data.ui_params.ball_radius,
            color  = BALL_COLOUR,
        }
    }

    return data
}

balls_update :: proc(dt: f32) {
    data := get_balls_data()

    if rl.IsKeyPressed(.C) {
        data.ui_params.show_ui = !data.ui_params.show_ui
    }

    if rl.IsKeyPressed(.ESCAPE) {
        set_level(.Menu)
        return
    }

    if data.ui_params.show_ui {
        process_ui_input(&data.mu_ctx)
        mu.begin(&data.mu_ctx)
        build_ui(&data.mu_ctx, &data.ui_params)
        mu.end(&data.mu_ctx)
    }

    // update balls
    speed_mult := data.ui_params.speed_multiplier
    for &ball in data.balls {
        ball.position.x += ball.velocity.x * dt * speed_mult
        ball.position.y += ball.velocity.y * dt * speed_mult
        ball.radius = data.ui_params.ball_radius
        check_bounds_ball(&ball)
    }
}

balls_render :: proc() {
    data := get_balls_data()

    rl.BeginMode2D(data.camera)
        for ball in data.balls {
            rl.DrawCircleV(ball.position, ball.radius, ball.color)
        }

        threshold_sq := data.ui_params.threshold * data.ui_params.threshold
        line_width := data.ui_params.line_width

        for i := 0; i < len(data.balls); i += 1 {
            for j := i + 1; j < len(data.balls); j += 1 {
                b1 := data.balls[i]
                b2 := data.balls[j]
                dx := b2.position.x - b1.position.x
                dy := b2.position.y - b1.position.y
                distance_squared := dx * dx + dy * dy
                if distance_squared <= threshold_sq {
                    alpha := ((threshold_sq - distance_squared) / threshold_sq) * 255
                    c := rl.Color{BALL_COLOUR[0], BALL_COLOUR[1], BALL_COLOUR[2], u8(alpha)}
                    rl.DrawLineEx(b1.position, b2.position, line_width, c)
                }
            }
        }
    rl.EndMode2D()

    if data.ui_params.show_ui {
        render_ui(&data.mu_ctx)
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
