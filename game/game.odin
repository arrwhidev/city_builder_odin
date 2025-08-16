package game

import "core:strconv/decimal"
import rl "vendor:raylib"

import "core:fmt"

GameMemory :: struct {
    window_width: i32,
    window_height: i32,
    balls: [MAX_BALLS]Ball,
}
g_mem: ^GameMemory

@(export)
game_init :: proc() {
    g_mem = new(GameMemory)
    g_mem^ = GameMemory {
        window_width = 400,
        window_height = 200,
    }
    init_balls(g_mem)


    rl.SetTargetFPS(60)
    rl.InitWindow(g_mem.window_width, g_mem.window_height, "hello")
}

@(export)
game_update :: proc() {
    dt := rl.GetFrameTime()
    
    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        update_balls(dt)
        render_balls()
        
        rl.DrawText(rl.TextFormat("fps: {0}", rl.GetFPS()), 10, 10, 20, rl.BLACK)
    rl.EndDrawing()
}

@(export)
game_running :: proc() -> bool {
    return !rl.WindowShouldClose()
}

@(export)
game_get_mem :: proc() -> rawptr {
    return g_mem
}

@(export)
game_get_mem_size :: proc() -> int {
    return size_of(GameMemory)
}

@(export)
game_hot_reload :: proc(mem: rawptr) {
    g_mem = (^GameMemory)(mem)
}

@(export)
game_close :: proc() {
    rl.CloseWindow()
    free(g_mem)
}