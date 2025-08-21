package game

import "core:fmt"
import "core:strconv/decimal"
import "core:mem"
import rl "vendor:raylib"

GameMemory :: struct {
    // sizing
    width: f32,
    height: f32,
    scale: f32,
    window_width: f32,
    window_height: f32,

    // flags
    debug: bool,

    // resources
    font: rl.Font,

    // game state
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
        width = 640,
        height = 360,
        scale = 2,
    }
    g_mem.window_width = g_mem.width * g_mem.scale
    g_mem.window_height = g_mem.height * g_mem.scale

    init_balls(g_mem)

    rl.SetTargetFPS(60)
    rl.InitWindow(i32(g_mem.window_width), i32(g_mem.window_height), "hello")

    // load resources
    g_mem.font = rl.LoadFont("./res/dungeonmode/font/font.ttf")
}

camera := rl.Camera2D {
    target = { 0, 0 },
    offset = { 0, 0 },
    rotation = 0,
    zoom = 1,
}

@(export)
game_update :: proc() {
    dt := rl.GetFrameTime()

    if rl.IsKeyDown(.RIGHT) {
        camera.zoom += 0.01
    } else if rl.IsKeyDown(.LEFT) {
        camera.zoom -= 0.01
    }

    rl.BeginDrawing()
        rl.BeginMode2D(camera)
            rl.ClearBackground(rl.RAYWHITE)
            update_balls(dt)
            render_balls()
        rl.EndMode2D()
        rl.DrawTextEx(g_mem.font, fmt.ctprintf("{0}", rl.GetFPS()), {10, 10}, 20, 1, rl.BLACK)
    rl.EndDrawing()

    free_all(context.temp_allocator)
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