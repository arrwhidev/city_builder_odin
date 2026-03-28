package game

import "core:math"
import rl "vendor:raylib"

CAMERA_PAN_SPEED :: 400
MOUSE_PAN_BUFFER_PIXELS :: 30

camera_update :: proc(dt: f32) {
    if !g_mem.cursor.is_in_bounds || g_mem.cursor.zone == .UI do return

    mouse_pos := rl.GetMousePosition()
    if mouse_pos.x > (g_mem.window_width - MOUSE_PAN_BUFFER_PIXELS) do g_mem.camera.target.x += CAMERA_PAN_SPEED * dt
    if mouse_pos.x >= UI_PANEL_WIDTH && mouse_pos.x < UI_PANEL_WIDTH + MOUSE_PAN_BUFFER_PIXELS do g_mem.camera.target.x -= CAMERA_PAN_SPEED * dt
    if mouse_pos.y > (g_mem.window_height - MOUSE_PAN_BUFFER_PIXELS) do g_mem.camera.target.y += CAMERA_PAN_SPEED * dt
    if mouse_pos.y < MOUSE_PAN_BUFFER_PIXELS do g_mem.camera.target.y -= CAMERA_PAN_SPEED * dt

    // Clamp target so the viewport never shows outside the map.
    num_cols := g_mem.map_data.num_cols
    num_rows := g_mem.map_data.num_rows
    map_w  := f32(num_cols * MAP_CELL_SIZE)
    map_h  := f32(num_rows * MAP_CELL_SIZE)
    viewport_half_w := (g_mem.window_width  / g_mem.camera.zoom) / 2
    viewport_half_h := (g_mem.window_height / g_mem.camera.zoom) / 2
    g_mem.camera.target.x = math.clamp(g_mem.camera.target.x, viewport_half_w, map_w - viewport_half_w)
    g_mem.camera.target.y = math.clamp(g_mem.camera.target.y, viewport_half_h, map_h - viewport_half_h)
}