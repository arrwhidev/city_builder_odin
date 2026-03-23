package game

import rl "vendor:raylib"


cursor_render :: proc() {
    mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), g_mem.camera)

    // Snap to cell grid
    cell_x := i32(mouse_world.x) / MAP_CELL_SIZE
    cell_y := i32(mouse_world.y) / MAP_CELL_SIZE

    if cell_x < 0 || cell_x >= MAP_SIZE || cell_y < 0 || cell_y >= MAP_SIZE {
        return
    }

    rl.DrawRectangleLinesEx(
        rl.Rectangle{
            f32(cell_x * MAP_CELL_SIZE),
            f32(cell_y * MAP_CELL_SIZE),
            MAP_CELL_SIZE,
            MAP_CELL_SIZE,
        },
        1,
        rl.ColorAlpha(rl.BLACK, 0.9),
    )
}
