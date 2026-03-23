package game

import rl "vendor:raylib"

MAP_SIZE      :: 128
MAP_CELL_SIZE :: 10

Cell :: struct {
	x: i32,
    y: i32,
    c: rl.Color,
    kind: CellKind,
}

CellKind :: enum {
    Grass,
    Water,
}

MapData :: struct {
    cells: [][]Cell,
}

Visible_Tiles :: struct {
    min_x, max_x, min_y, max_y: int,
}

map_init :: proc() -> MapData {
    cells := make([][]Cell, MAP_SIZE)
    for y in 0..<MAP_SIZE {
        cells[y] = make([]Cell, MAP_SIZE)
        for x in 0..<MAP_SIZE {
            cells[y][x] = Cell{
                x = i32(x),
                y = i32(y),
                c = rl.Color{
                    u8(rl.GetRandomValue(0, 255)), 
                    u8(rl.GetRandomValue(0, 255)), 
                    u8(rl.GetRandomValue(0, 255)), 
                    255,
                },
                kind = rl.GetRandomValue(1, 10) > 5 ? CellKind.Grass : CellKind.Water,
            }
        }
    }
    return MapData{cells = cells}
}

map_render :: proc() {
    vt := visible_tiles()
    for y in vt.min_y..<vt.max_y {
        for x in vt.min_x..<vt.max_x {
            cell := get_cell(x, y)
            rl.DrawRectangle(
                cell.x * MAP_CELL_SIZE,
                cell.y * MAP_CELL_SIZE,
                MAP_CELL_SIZE,
                MAP_CELL_SIZE,
                cell.c,
            )
        }
    }
}

map_update :: proc(dt: f32) {
}

get_cell :: proc(x, y: int) -> ^Cell {
    return &g_mem.mapData.cells[y][x]
}

visible_tiles :: proc() -> Visible_Tiles {
    view_half_w := (g_mem.window_width  / g_mem.camera.zoom) / 2
    view_half_h := (g_mem.window_height / g_mem.camera.zoom) / 2
    cam := &g_mem.camera.target

    return {
        min_x = max(0,        int((cam.x - view_half_w) / MAP_CELL_SIZE)),
        min_y = max(0,        int((cam.y - view_half_h) / MAP_CELL_SIZE)),
        max_x = min(MAP_SIZE, int((cam.x + view_half_w) / MAP_CELL_SIZE) + 1),
        max_y = min(MAP_SIZE, int((cam.y + view_half_h) / MAP_CELL_SIZE) + 1),
    }
}