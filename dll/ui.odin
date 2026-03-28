package game

import rl "vendor:raylib"


BUTTONS_PER_ROW :: 3
BUTTON_WIDTH    :: 60
BUTTON_HEIGHT   :: 30
BUTTON_MARGIN   :: 4

UI_PANEL_WIDTH           :: BUTTONS_PER_ROW * BUTTON_WIDTH + ((BUTTONS_PER_ROW + 1) * BUTTON_MARGIN)
UI_FONT_SPACING          :: 1
UI_FONT_SIZE             :: 8
UI_PANEL_BG_COLOUR       :: rl.Color{30,  30,  30,  220}
UI_BUTTON_BG_COLOUR      :: rl.Color{60,  60,  60,  255}
UI_BUTTON_SEL_COLOUR     :: rl.Color{80,  160, 80,  255}
UI_BUTTON_BORDER_COLOUR  :: rl.Color{120, 120, 120, 255}
UI_BUTTON_TEXT_COLOUR    :: rl.WHITE
UI_BUTTON_LINE_THICKNESS :: 1


UIRow :: struct {
    buttons: [BUTTONS_PER_ROW]UIButton,
}

UIButton :: struct {
    label:     cstring,
    tool_type: ToolType,
}

// Compile-time fixed UI layout
UI_ROWS :: [?]UIRow{{
    buttons = {
        {label = "None",   tool_type = .None},
        {label = "Eraser", tool_type = .Eraser},
        {label = "Road",   tool_type = .Road},
    },
}}

ui_update :: proc(dt: f32) {
    mouse := rl.GetMousePosition()
    if mouse.x > UI_PANEL_WIDTH do return
    if !rl.IsMouseButtonPressed(.LEFT) do return

    for row, ri in UI_ROWS {
        for btn, ci in row.buttons {
            if rl.CheckCollisionPointRec(mouse, ui_button_rect(ri, ci)) {
                g_mem.tool.mode = btn.tool_type
            }
        }
    }
}

ui_render :: proc() {
    rl.DrawRectangleRec(
        {0, 0, UI_PANEL_WIDTH, f32(rl.GetScreenHeight())},
        UI_PANEL_BG_COLOUR,
    )

    for row, ri in UI_ROWS {
        for btn, ci in row.buttons {
            selected := g_mem.tool.mode == btn.tool_type
            rect     := ui_button_rect(ri, ci)
            bg := selected ? UI_BUTTON_SEL_COLOUR : UI_BUTTON_BG_COLOUR

            text_w := rl.MeasureTextEx(g_mem.font, btn.label, UI_FONT_SIZE, UI_FONT_SPACING).x

            rl.DrawRectangleRec(rect, bg)
            rl.DrawRectangleLinesEx(rect, UI_BUTTON_LINE_THICKNESS, UI_BUTTON_BORDER_COLOUR)
            rl.DrawTextEx(
                g_mem.font,
                btn.label,
                {
                    rect.x + (BUTTON_WIDTH - text_w) / 2, 
                    rect.y + (BUTTON_HEIGHT - UI_FONT_SIZE) / 2,
                },
                UI_FONT_SIZE,
                UI_FONT_SPACING,
                UI_BUTTON_TEXT_COLOUR,
            )
        }
    }
}

@(private = "file")
ui_button_rect :: proc(row, col: int) -> rl.Rectangle {
    x := BUTTON_MARGIN + col * (BUTTON_WIDTH + BUTTON_MARGIN)
    y := BUTTON_MARGIN + row * (BUTTON_HEIGHT + BUTTON_MARGIN)
    return {f32(x), f32(y), BUTTON_WIDTH, BUTTON_HEIGHT}
}
