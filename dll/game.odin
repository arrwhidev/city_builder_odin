package game

import "core:fmt"
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
    quit: bool,

    // resources
    font: rl.Font,

    // memory
    permanent_arena: mem.Arena,
    level_arena: mem.Arena,
    level_arena_backing: []byte,

    // level
    current_level_type: LevelType,
    current_level: LevelProcs,
    level_data: rawptr,
}
g_mem: ^GameMemory

@(export)
game_init :: proc(data: []byte) {
    // Set up permanent arena from the full 4MB
    permanent_arena: mem.Arena
    mem.arena_init(&permanent_arena, data)
    permanent_alloc := mem.arena_allocator(&permanent_arena)

    // Allocate GameMemory from permanent arena
    g_mem = new(GameMemory, permanent_alloc)
    g_mem^ = GameMemory {
        width = 640,
        height = 360,
        scale = 2,
        debug = true,
    }
    g_mem.window_width = g_mem.width * g_mem.scale
    g_mem.window_height = g_mem.height * g_mem.scale

    // Store the permanent arena in GameMemory (so it persists)
    g_mem.permanent_arena = permanent_arena

    // Everything after this point is available for level memory
    g_mem.level_arena_backing = data[permanent_arena.offset:]

    rl.SetTargetFPS(120)
    rl.InitWindow(i32(g_mem.window_width), i32(g_mem.window_height), "hello")
    rl.SetExitKey(.KEY_NULL) // we handle ESC ourselves

    // load resources
    g_mem.font = rl.LoadFont("./res/dungeonmode/font/font.ttf")

    // set starting level
    set_level(.Menu)
}

@(export)
game_update :: proc() {
    dt := rl.GetFrameTime()

    if g_mem.current_level.update != nil {
        g_mem.current_level.update(dt)
    }

    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        if g_mem.current_level.render != nil {
            g_mem.current_level.render()
        }

        if g_mem.debug {
            rl.DrawTextEx(g_mem.font, fmt.ctprintf("{0}", rl.GetFPS()), {10, 10}, 20, 1, rl.BLACK)
        }
    rl.EndDrawing()

    free_all(context.temp_allocator)
}

set_level :: proc(level_type: LevelType) {
    g_mem.level_data = nil

    // reset level arena - this "frees" all level memory
    mem.arena_init(&g_mem.level_arena, g_mem.level_arena_backing)

    // set and init new level
    g_mem.current_level_type = level_type
    g_mem.current_level = LEVEL_PROCS[level_type]
    if g_mem.current_level.init != nil {
        g_mem.level_data = g_mem.current_level.init()
    }
}

// Returns an allocator for level-scoped memory (freed when level changes)
level_allocator :: proc() -> mem.Allocator {
    return mem.arena_allocator(&g_mem.level_arena)
}

@(export)
game_running :: proc() -> bool {
    return !rl.WindowShouldClose() && !g_mem.quit
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
game_hot_reload :: proc(m: rawptr) {
    g_mem = (^GameMemory)(m)
    // Refresh function pointers from new DLL
    g_mem.current_level = LEVEL_PROCS[g_mem.current_level_type]
}

@(export)
game_close :: proc() {
    rl.CloseWindow()
    // g_mem lives in the 4MB managed by main, no free needed
}