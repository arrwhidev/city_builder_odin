package game

LevelType :: enum {
    None,
    Menu,
    Balls,
}

LevelProcs :: struct {
    init:   proc() -> rawptr,
    update: proc(dt: f32),
    render: proc(),
}

LEVEL_PROCS : [LevelType]LevelProcs = {
    .None  = {},
    .Menu  = {init = menu_init, update = menu_update, render = menu_render},
    .Balls = {init = balls_init, update = balls_update, render = balls_render},
}
