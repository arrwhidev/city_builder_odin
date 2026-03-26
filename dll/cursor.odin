package game

import rl "vendor:raylib"

CursorMode :: enum {
    None,
    Eraser,
    Road,
}

CursorData :: struct {
    mode: CursorMode,
    is_in_bounds: bool,
    is_tool_allowed: bool,
    cell_x: int,
    cell_y: int,
}

cursor_update :: proc(dt: f32) {
    update_mouse_cell()
    if !g_mem.cursor.is_in_bounds do return
    if rl.GetMousePosition().x <= PANEL_WIDTH do return

    if rl.IsKeyPressed(.E) do set_cursor_tool(.Eraser)
    if rl.IsKeyPressed(.R) do set_cursor_tool(.Road)
    if rl.IsMouseButtonDown(.LEFT) {
        if g_mem.cursor.is_tool_allowed {
            switch g_mem.cursor.mode {
            case .None:   break
            case .Eraser: erase_at_cursor()
            case .Road:   set_road_at_cursor()
            }
        }
    }
}

cursor_render :: proc() {
    if g_mem.cursor.is_in_bounds {
        rect_colour := g_mem.cursor.is_tool_allowed ? rl.BLACK : rl.RED
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

reset_cursor_tool :: proc() {
    g_mem.cursor.mode = .None
}

set_cursor_tool :: proc(mode: CursorMode) {
    g_mem.cursor.mode = mode
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
    g_mem.cursor.is_tool_allowed = is_tool_allowed()
}

is_tool_allowed :: proc() -> bool {
    cell := get_cell(g_mem.cursor.cell_x, g_mem.cursor.cell_y)

    if g_mem.cursor.mode == .Eraser do return cell.kind == .Road // can only erase road
    if g_mem.cursor.mode == .Road   do return cell.kind == .None && cell.map_tile_kind == .Grass // can only place road on grass that is not already road
    return false
}