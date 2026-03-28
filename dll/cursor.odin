package game

import rl "vendor:raylib"

ScreenZone :: enum { UI, Game }
CursorData :: struct {
    zone        : ScreenZone,
    is_in_bounds: bool,
    cell_x:       int,
    cell_y:       int,
}

cursor_update :: proc(dt: f32) {
    update_mouse_cell()
}

cursor_render :: proc() {
    if g_mem.cursor.is_in_bounds {
        rect_colour := g_mem.tool.can_apply ? rl.BLACK : rl.RED
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
    mouse_pos := rl.GetMousePosition()

    in_window := mouse_pos.x >= 0 && mouse_pos.x < g_mem.window_width &&
                 mouse_pos.y >= 0 && mouse_pos.y < g_mem.window_height
    g_mem.cursor.is_in_bounds = in_window

    g_mem.cursor.zone = .UI if mouse_pos.x < UI_PANEL_WIDTH else .Game

    if !in_window || g_mem.cursor.zone == .UI {
        g_mem.cursor.cell_x = 0
        g_mem.cursor.cell_y = 0
        return
    }

    mouse_world := rl.GetScreenToWorld2D(mouse_pos, g_mem.camera)

    cell_x := int(mouse_world.x) / MAP_CELL_SIZE
    cell_y := int(mouse_world.y) / MAP_CELL_SIZE

    num_cols := g_mem.map_data.num_cols
    num_rows := g_mem.map_data.num_rows

    if cell_x < 0 || cell_x >= num_cols || cell_y < 0 || cell_y >= num_rows {
        return
    }

    g_mem.cursor.cell_x = cell_x
    g_mem.cursor.cell_y = cell_y
}