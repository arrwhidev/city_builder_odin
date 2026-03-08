package game

import rl "vendor:raylib"

MENU_ITEMS :: []cstring{
    "Balls",
    "Another",
}

MenuLevelData :: struct {
    selection: int,
}

get_menu_data :: proc() -> ^MenuLevelData {
    return cast(^MenuLevelData)g_mem.level_data
}

menu_init :: proc() -> rawptr {
    return new(MenuLevelData, level_allocator())
}

menu_update :: proc(dt: f32) {
    data := get_menu_data()

    if rl.IsKeyPressed(.ESCAPE) {
        g_mem.quit = true
        return
    }

    if rl.IsKeyPressed(.UP) {
        data.selection -= 1
        if data.selection < 0 {
            data.selection = len(MENU_ITEMS) - 1
        }
    }
    if rl.IsKeyPressed(.DOWN) {
        data.selection += 1
        if data.selection >= len(MENU_ITEMS) {
            data.selection = 0
        }
    }
    if rl.IsKeyPressed(.ENTER) {
        switch data.selection {
        case 0:
            set_level(.Balls)
        }
    }
}

menu_render :: proc() {
    data := get_menu_data()

    font_size: f32 = 20
    spacing: f32 = 30
    start_y: f32 = g_mem.window_height / 2 - (f32(len(MENU_ITEMS)) * spacing) / 2

    for item, i in MENU_ITEMS {
        y := start_y + f32(i) * spacing
        x: f32 = g_mem.window_width / 2 - 50

        color := rl.LIGHTGRAY
        if i == data.selection {
            color = rl.BLACK
            rl.DrawTextEx(g_mem.font, ">", {x - 30, y}, font_size, 1, rl.BLACK)
        }

        rl.DrawTextEx(g_mem.font, item, {x, y}, font_size, 1, color)
    }
}
