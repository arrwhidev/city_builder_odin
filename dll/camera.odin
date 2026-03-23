package game

import "core:math"
import rl "vendor:raylib"

CAMERA_PAN_SPEED :: 200
MOUSE_PAN_BUFFER_PIXELS :: 50

camera_update :: proc(dt: f32) {
    mouse_pos := rl.GetMousePosition()
    if mouse_pos.x > (g_mem.window_width - MOUSE_PAN_BUFFER_PIXELS) do g_mem.camera.target.x += CAMERA_PAN_SPEED * dt
    if mouse_pos.x < MOUSE_PAN_BUFFER_PIXELS do g_mem.camera.target.x -= CAMERA_PAN_SPEED * dt
    if mouse_pos.y > (g_mem.window_height - MOUSE_PAN_BUFFER_PIXELS) do g_mem.camera.target.y += CAMERA_PAN_SPEED * dt
    if mouse_pos.y < MOUSE_PAN_BUFFER_PIXELS do g_mem.camera.target.y -= CAMERA_PAN_SPEED * dt

    // Clamp target so the viewport never shows outside the map.
    map_w  := f32(MAP_SIZE * MAP_CELL_SIZE)
    map_h  := f32(MAP_SIZE * MAP_CELL_SIZE)
    viewport_half_w := (g_mem.window_width  / g_mem.camera.zoom) / 2
    viewport_half_h := (g_mem.window_height / g_mem.camera.zoom) / 2
    g_mem.camera.target.x = math.clamp(g_mem.camera.target.x, viewport_half_w, map_w - viewport_half_w)
    g_mem.camera.target.y = math.clamp(g_mem.camera.target.y, viewport_half_h, map_h - viewport_half_h)
}