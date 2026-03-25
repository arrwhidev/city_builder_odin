package game

import rl "vendor:raylib"

CursorData :: struct {
    is_in_bounds: bool,
    can_create: bool,
    cell_x: int,
    cell_y: int,
}

cursor_update :: proc(dt: f32) {
    update_mouse_cell()
    if !g_mem.cursor.is_in_bounds {
        return
    }

    if rl.IsMouseButtonDown(.LEFT) && g_mem.cursor.can_create {
        set_road_at_cursor()
    }
}

cursor_render :: proc() {
    if g_mem.cursor.is_in_bounds {
        rect_colour : = g_mem.cursor.can_create ? rl.BLACK : rl.RED
        rl.DrawRectangleLinesEx(
            rl.Rectangle{
                f32(g_mem.cursor.cell_x * MAP_CELL_SIZE),
                f32(g_mem.cursor.cell_y * MAP_CELL_SIZE),
                MAP_CELL_SIZE,
                MAP_CELL_SIZE,
            },
            1,
            rl.ColorAlpha(rect_colour, 0.9),
        )
    }
}

@(private="file")
update_mouse_cell :: proc() {
    mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), g_mem.camera)

    // Snap to cell grid
    cell_x := int(mouse_world.x) / MAP_CELL_SIZE
    cell_y := int(mouse_world.y) / MAP_CELL_SIZE

    num_cols := g_mem.map_data.num_cols
    num_rows := g_mem.map_data.num_rows

    if cell_x < 0 || cell_x >= num_cols || cell_y < 0 || cell_y >= num_rows {
        g_mem.cursor.is_in_bounds = false
        return
    }
        
    g_mem.cursor.is_in_bounds = true
    g_mem.cursor.cell_x = cell_x
    g_mem.cursor.cell_y = cell_y
    g_mem.cursor.can_create = is_cursor_cell_creatable()
}