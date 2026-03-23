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

get_cell :: proc(x, y: int) -> ^Cell {
    return &g_mem.mapData.cells[y][x]
}

map_render :: proc() {
    for y in 0..<MAP_SIZE {
        for x in 0..<MAP_SIZE {
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
