package game

import "core:os"
import "core:strings"
import rl "vendor:raylib"

parse_map :: proc(name: string) -> MapData {
    // Cache the main arena allocator for later.
    arena_allocator := context.allocator 

    // Set the context allocator to use the temp_allocator for the following string/file allocations.
    // I pass arena_allocator specifically to make() calls where required.
    context.allocator = context.temp_allocator

    path := strings.concatenate({"res/maps/", name, ".csv"})
    data, ok := os.read_entire_file(path)
    if !ok {
        // TODO: handle error
    }

    content := string(data)
    lines := strings.split_lines(strings.trim_right(content, "\n\r"))

    rows := len(lines)
    cells := make([][]Cell, rows, arena_allocator)

    for line, y in lines {
        parts := strings.split(line, ",")

        cells[y] = make([]Cell, len(parts), arena_allocator)
        for token, x in parts {
            kind: CellKind
            color: rl.Color
            switch token {
            case "g":
                kind  = .Grass
                color = rl.GREEN
            case "w":
                kind  = .Water
                color = rl.BLUE
            }
            cells[y][x] = Cell{
                x = i32(x), 
                y = i32(y), 
                c = color, 
                kind = kind,
            }
        }
    }

    free_all(context.temp_allocator)
    return MapData{
        cells = cells,
        num_rows = rows,
        num_cols = len(cells[0]),
    }
}
