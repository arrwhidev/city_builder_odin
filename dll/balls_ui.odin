package game

import "core:strings"
import mu "vendor:microui"
import rl "vendor:raylib"

UI_FONT_SIZE :: 8
UI_FONT_SPACING :: 1

// Text width callback for microui using raylib
text_width :: proc(font: mu.Font, str: string) -> i32 {
    cstr := strings.clone_to_cstring(str, context.temp_allocator)
    return i32(rl.MeasureTextEx(g_mem.font, cstr, UI_FONT_SIZE, UI_FONT_SPACING).x)
}

// Text height callback for microui
text_height :: proc(font: mu.Font) -> i32 {
    return UI_FONT_SIZE
}

// Initialize microui context
init_ui :: proc(ctx: ^mu.Context) {
    mu.init(ctx)
    ctx.text_width = text_width
    ctx.text_height = text_height
}

// Process raylib input and feed to microui
process_ui_input :: proc(ctx: ^mu.Context) {
    mouse_pos := rl.GetMousePosition()
    mu.input_mouse_move(ctx, i32(mouse_pos.x), i32(mouse_pos.y))

    // Mouse buttons
    mouse_buttons := [?]struct{rl_btn: rl.MouseButton, mu_btn: mu.Mouse}{
        {.LEFT, .LEFT},
        {.RIGHT, .RIGHT},
        {.MIDDLE, .MIDDLE},
    }
    for btn in mouse_buttons {
        if rl.IsMouseButtonPressed(btn.rl_btn) {
            mu.input_mouse_down(ctx, i32(mouse_pos.x), i32(mouse_pos.y), btn.mu_btn)
        }
        if rl.IsMouseButtonReleased(btn.rl_btn) {
            mu.input_mouse_up(ctx, i32(mouse_pos.x), i32(mouse_pos.y), btn.mu_btn)
        }
    }

    // Scroll
    scroll := rl.GetMouseWheelMove()
    if scroll != 0 {
        mu.input_scroll(ctx, 0, i32(scroll * -30))
    }
}

// Build the UI - called every frame
build_ui :: proc(ctx: ^mu.Context, params: ^UIParams) {
    if mu.window(ctx, "Settings", {10, 40, 220, 280}, {.NO_CLOSE}) {
        // Threshold slider
        mu.layout_row(ctx, {-1}, 0)
        mu.label(ctx, "Threshold")
        mu.layout_row(ctx, {-1}, 0)
        mu.slider(ctx, &params.threshold, 10, 150, 1, "%.0f")

        // Ball radius slider
        mu.layout_row(ctx, {-1}, 0)
        mu.label(ctx, "Ball Radius")
        mu.layout_row(ctx, {-1}, 0)
        mu.slider(ctx, &params.ball_radius, 1, 20, 0.5, "%.1f")

        // Speed multiplier slider
        mu.layout_row(ctx, {-1}, 0)
        mu.label(ctx, "Speed")
        mu.layout_row(ctx, {-1}, 0)
        mu.slider(ctx, &params.speed_multiplier, 0.1, 3.0, 0.1, "%.1f")

        // Line width slider
        mu.layout_row(ctx, {-1}, 0)
        mu.label(ctx, "Line Width")
        mu.layout_row(ctx, {-1}, 0)
        mu.slider(ctx, &params.line_width, 0.5, 5.0, 0.25, "%.2f")
    }
}

// Render microui commands using raylib
render_ui :: proc(ctx: ^mu.Context) {
    cmd: ^mu.Command
    for mu.next_command(ctx, &cmd) {
        switch v in cmd.variant {
        case ^mu.Command_Text:
            cstr := strings.clone_to_cstring(v.str, context.temp_allocator)
            rl.DrawTextEx(g_mem.font, cstr, {f32(v.pos.x), f32(v.pos.y)}, UI_FONT_SIZE, UI_FONT_SPACING, transmute(rl.Color)v.color)
        case ^mu.Command_Rect:
            rl.DrawRectangle(v.rect.x, v.rect.y, v.rect.w, v.rect.h, transmute(rl.Color)v.color)
        case ^mu.Command_Icon:
            // Simple icon rendering - just draw a symbol
            icon_char: cstring
            #partial switch v.id {
            case .CLOSE: icon_char = "x"
            case .CHECK: icon_char = "v"
            case .EXPANDED: icon_char = "-"
            case .COLLAPSED: icon_char = "+"
            case: icon_char = ""
            }
            if len(icon_char) > 0 {
                x := f32(v.rect.x + (v.rect.w - 8) / 2)
                y := f32(v.rect.y + (v.rect.h - UI_FONT_SIZE) / 2)
                rl.DrawTextEx(g_mem.font, icon_char, {x, y}, UI_FONT_SIZE, UI_FONT_SPACING, transmute(rl.Color)v.color)
            }
        case ^mu.Command_Clip:
            rl.EndScissorMode()
            if v.rect.w > 0 && v.rect.h > 0 {
                rl.BeginScissorMode(v.rect.x, v.rect.y, v.rect.w, v.rect.h)
            }
        case ^mu.Command_Jump:
        }
    }
    rl.EndScissorMode()
}
