package game

import "core:fmt"
import "core:strconv/decimal"
import "core:mem"
import rl "vendor:raylib"

GameMemory :: struct {
    window_width: i32,
    window_height: i32,
    balls: [MAX_BALLS]Ball,
}
g_mem: ^GameMemory
g_arena_alloc: mem.Allocator

@(export)
game_init :: proc(data: []byte) {
    arena: mem.Arena
    mem.arena_init(&arena, data)
    g_arena_alloc = mem.arena_allocator(&arena)

    g_mem = new(GameMemory, g_arena_alloc)
    g_mem^ = GameMemory {
        window_width = 600,
        window_height = 300,
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