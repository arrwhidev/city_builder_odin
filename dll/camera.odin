package game

import "core:math"
import rl "vendor:raylib"

CAMERA_PAN_SPEED :: 200

camera_update :: proc(dt: f32) {
    if rl.IsKeyDown(.RIGHT) do g_mem.camera.target.x += CAMERA_PAN_SPEED * dt
    if rl.IsKeyDown(.LEFT)  do g_mem.camera.target.x -= CAMERA_PAN_SPEED * dt
    if rl.IsKeyDown(.DOWN)  do g_mem.camera.target.y += CAMERA_PAN_SPEED * dt
    if rl.IsKeyDown(.UP)    do g_mem.camera.target.y -= CAMERA_PAN_SPEED * dt

    // Clamp target so the viewport never shows outside the map.
    map_w  := f32(MAP_SIZE * MAP_CELL_SIZE)
    map_h  := f32(MAP_SIZE * MAP_CELL_SIZE)
    half_w := (g_mem.window_width  / g_mem.camera.zoom) / 2
    half_h := (g_mem.window_height / g_mem.camera.zoom) / 2

    g_mem.camera.target.x = math.clamp(g_mem.camera.target.x, half_w, map_w - half_w)
    g_mem.camera.target.y = math.clamp(g_mem.camera.target.y, half_h, map_h - half_h)
}