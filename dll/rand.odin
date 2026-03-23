package game 

import rl "vendor:raylib"

random_color :: proc(alpha: u8 = 255) -> rl.Color {
    return rl.Color{
        u8(rl.GetRandomValue(0, 255)), 
        u8(rl.GetRandomValue(0, 255)), 
        u8(rl.GetRandomValue(0, 255)), 
        alpha,
    },
}