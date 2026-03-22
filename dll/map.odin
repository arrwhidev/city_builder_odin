package game

import rl "vendor:raylib"

MAP_SIZE :: 128

Cell :: struct {
	x: i32,
    y: i32,
    c: rl.Color,
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
            rl.DrawRectangle(cell.x * 10, cell.y * 10, 10, 10, cell.c)
        }
    }
}

map_update :: proc(dt: f32) {
    
}
