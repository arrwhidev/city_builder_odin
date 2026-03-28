package game

import rl "vendor:raylib"

// ToolType is the one place to add a new tool.
// After adding a variant here, add behaviour to is_tool_allowed and apply_tool_at_cursor below,
// then add a button entry to UI_ROWS in ui.odin.
ToolType :: enum {
    None,
    Eraser,
    Road,
}

ToolState :: struct {
    mode:      ToolType,
    can_apply: bool,
}

tool_update :: proc(dt: f32) {
    if rl.IsKeyPressed(.E) do g_mem.tool.mode = .Eraser
    if rl.IsKeyPressed(.R) do g_mem.tool.mode = .Road

    if !g_mem.cursor.is_in_bounds || rl.GetMousePosition().x <= UI_PANEL_WIDTH {
        g_mem.tool.can_apply = false
        return
    }

    cell := get_cell(g_mem.cursor.cell_x, g_mem.cursor.cell_y)
    g_mem.tool.can_apply = is_tool_allowed(g_mem.tool.mode, cell)

    if rl.IsMouseButtonDown(.LEFT) do apply_tool_at_cursor()
}

is_tool_allowed :: proc(mode: ToolType, cell: ^Cell) -> bool {
    if mode == .Eraser do return cell.kind == .Road
    if mode == .Road   do return cell.kind == .None && cell.map_tile_kind == .Grass
    return false
}

apply_tool_at_cursor :: proc() {
    if g_mem.cursor.is_in_bounds && g_mem.tool.can_apply {
        cell := get_cell(g_mem.cursor.cell_x, g_mem.cursor.cell_y)
        switch g_mem.tool.mode {
        case .None:   break
        case .Eraser: cell.kind = .None
        case .Road:   cell.kind = .Road
        }
    }
}
