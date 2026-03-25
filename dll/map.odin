package game

import rl "vendor:raylib"

MAP_CELL_SIZE :: 10

Cell :: struct {
	x: i32,
    y: i32,
    map_tile_kind: MapTileKind,
    kind: Kind,
}

MapTileKind :: enum {
    Grass,
    Water,
}

Kind :: enum {
    None,
    Road,
}

MapData :: struct {
    cells: [][]Cell,
    num_cols: int,
    num_rows: int,
}

Visible_Cells :: struct {
    min_x, max_x, min_y, max_y: int,
}

map_init :: proc(map_name: string = "map1") -> MapData {
    return parse_map(map_name)
}

get_cell_color :: proc(cell: ^Cell) -> rl.Color {
    switch (cell.map_tile_kind) {
    case MapTileKind.Grass:
        return rl.GREEN
    case MapTileKind.Water:
        return rl.BLUE
    case:
        return rl.MAGENTA // ring the bell!
    }
}

map_render :: proc() {
    vt := visible_cells()
    for y in vt.min_y..<vt.max_y {
        for x in vt.min_x..<vt.max_x {
            cell := get_cell(x, y)
            colour := get_cell_color(cell)

            rl.DrawRectangle(
                cell.x * MAP_CELL_SIZE,
                cell.y * MAP_CELL_SIZE,
                MAP_CELL_SIZE,
                MAP_CELL_SIZE,
                colour,
            )

            if (cell.kind == Kind.Road) {
                rl.DrawRectangle(
                    (cell.x * MAP_CELL_SIZE) + 1,
                    (cell.y * MAP_CELL_SIZE) + 1,
                    MAP_CELL_SIZE - 2,
                    MAP_CELL_SIZE - 2,
                    rl.GRAY,
                )
            }
        }
    }
}

map_update :: proc(dt: f32) {
}

get_cell :: proc(x, y: int) -> ^Cell {
    return &g_mem.map_data.cells[y][x]
}

get_num_cols :: proc() -> int {
    return g_mem.map_data.num_cols
}

get_num_rows :: proc() -> int {
    return g_mem.map_data.num_rows
}

visible_cells :: proc() -> Visible_Cells {
    viewport_half_w := (g_mem.window_width  / g_mem.camera.zoom) / 2
    viewport_half_h := (g_mem.window_height / g_mem.camera.zoom) / 2
    cam := &g_mem.camera.target

    return {
        min_x = max(0,              int((cam.x - viewport_half_w) / MAP_CELL_SIZE)),
        min_y = max(0,              int((cam.y - viewport_half_h) / MAP_CELL_SIZE)),
        max_x = min(get_num_cols(), int((cam.x + viewport_half_w) / MAP_CELL_SIZE) + 1),
        max_y = min(get_num_rows(), int((cam.y + viewport_half_h) / MAP_CELL_SIZE) + 1),
    }
}