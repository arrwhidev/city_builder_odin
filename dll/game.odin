package game

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

GameMemory :: struct {
    // allocator
    arena: mem.Arena,

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

    // camera
    camera: rl.Camera2D,

    // game data
    mapData: MapData,
    ballData: BallData,
}

// Pointer to game memory.
g_mem: ^GameMemory

@(export)
game_init :: proc(data: []byte) {
    // Bootstrap: create a temporary arena from the raw block so we can
    // allocate GameMemory itself inside it.
    arena: mem.Arena
    mem.arena_init(&arena, data)
    arena_allocator := mem.arena_allocator(&arena)
    context.allocator = arena_allocator

    // GameMemory now lives at the start of the 4MB block.
    // The arena's offset advances past it; subsequent allocations follow.
    g_mem = new(GameMemory)
    g_mem^ = GameMemory {
        width = 1280,
        height = 640,
        scale = 1,
        debug = true,
        arena = arena, // we may not need to store this but probably useful.
    }
    g_mem.window_width = g_mem.width * g_mem.scale
    g_mem.window_height = g_mem.height * g_mem.scale

    // rl.SetConfigFlags{.VSYNC}
    rl.SetTargetFPS(120)
    rl.InitWindow(i32(g_mem.window_width), i32(g_mem.window_height), "zeus")

    g_mem.font = rl.LoadFont("./res/dungeonmode/font/font.ttf")

    // Camera init
    map_world_size := f32(MAP_SIZE * MAP_CELL_SIZE)
    g_mem.camera = rl.Camera2D {
        offset   = {g_mem.window_width / 2, g_mem.window_height / 2}, // screen-space: pin to window centre
        target   = {map_world_size / 2, map_world_size / 2},          // world-space: centre of map
        rotation = 0,
        zoom     = 2,
    }

    // Game data init
    g_mem.mapData = map_init()
    g_mem.ballData = balls_init()

    used := f64(arena.offset) / (1024 * 1024)
    total := f64(len(arena.data)) / (1024 * 1024)
    fmt.printfln("memory used: %.4fMB / %.0fMB (%.3f%%)", used, total, (used / total * 100))
}

@(export)
game_update :: proc() {
    dt := rl.GetFrameTime()

    map_update(dt)
    balls_update(dt)
    camera_update(dt)

    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        rl.BeginMode2D(g_mem.camera)
            map_render()
            balls_render()
            cursor_render()
        rl.EndMode2D()

        if g_mem.debug {
            rl.DrawTextEx(g_mem.font, fmt.ctprintf("{0}", rl.GetFPS()), {10, 10}, 15, 1, rl.BLACK)
        }
    rl.EndDrawing()

    // Wipe the temp allocator at the end of every frame.
    // Anything allocated with context.temp_allocator (e.g. fmt.tprintf strings)
    // is only valid for the current frame — do not hold pointers across frames.
    free_all(context.temp_allocator)
}

@(export)
game_running :: proc() -> bool {
    return !rl.WindowShouldClose() && !g_mem.quit
}

// Returns a raw pointer to GameMemory so main can pass it back on hot reload.
// The pointer points into the 4MB block — main owns the block, not us.
@(export)
game_get_mem :: proc() -> rawptr {
    return g_mem
}

// Used by main to detect whether GameMemory layout changed between reloads.
// If the size differs, main performs a hard reset instead of a hot reload.
@(export)
game_get_mem_size :: proc() -> int {
    return size_of(GameMemory)
}

// Hot reload path: the new DLL receives the pointer to existing live data
// and simply casts it back to ^GameMemory. No copying, no re-initialisation.
@(export)
game_hot_reload :: proc(m: rawptr) {
    g_mem = (^GameMemory)(m)
}

@(export)
game_close :: proc() {
    rl.CloseWindow()
}
