package main

import "core:dynlib"
import "core:os"
import "core:fmt"

GameAPI :: struct {
	init: proc(),
	close: proc(),
	update: proc(),
	running: proc() -> bool,
	hot_reload: proc(mem: rawptr),
	get_mem: proc() -> rawptr,
	get_mem_size: proc() -> int,
}

dll_last_time: os.File_Time = 0

main :: proc() {	
	api, ok := load_dll()
	if !ok {
		fmt.printfln("failed to load game dll, exiting program")
		os.exit(1)
	}

	api.init()
	fmt.println("(after init)api.get_mem=", api.get_mem())
	for api.running() {
		api.update()

		new_api, reloaded := maybe_reload_dll()
		if reloaded {
			new_mem_size := new_api.get_mem_size()
			if new_mem_size != api.get_mem_size() {
				fmt.println("mem size mismatch, hard resetting...")
				api.close()
				new_api.init()
				api = new_api
			} else {
				fmt.println("mem size match, hot reloading...")
				old_mem := api.get_mem()
				m := api.get_mem()
				api = new_api
				new_api.hot_reload(m)
			}
		}
	}
	api.close()
}

maybe_reload_dll :: proc() -> (api: GameAPI, reloaded: bool = false) {
	dll_path :: "out/game.dylib"
	dll_time, dll_time_err := os.last_write_time_by_name(dll_path)
	if dll_time_err != os.ERROR_NONE {
		// do not error just move on (this happens when dll has not finished rebuilding)
		fmt.eprintln("Could not fetch last write date of game.dll, error=", dll_time_err)
		return
	}

	if dll_time > dll_last_time {
		fmt.println("dll has changed, reloading...")
		return load_dll()
	}

	return 
}

load_dll :: proc() -> (api: GameAPI, ok: bool = false) {
	dll_path :: "out/game.dylib"
	dll_time, dll_time_err := os.last_write_time_by_name(dll_path)

	if dll_time_err != os.ERROR_NONE {
		fmt.println("Could not fetch last write date of game.dll")
		return
  	}
	fmt.println("dll time checked successfully, lasted touched at:", dll_time)

	_, ok = dynlib.initialize_symbols(&api, dll_path, "game_")
	if !ok {
		fmt.printfln("failed initializing symbols: {0}", dynlib.last_error())
		return
	}
	fmt.println("dll loaded successfully:", api)

	if api.init == nil || api.update == nil || api.close == nil || api.running == nil || api.hot_reload == nil || api.get_mem == nil {
		fmt.println("Failed to init game api struct")
	}

	dll_last_time = dll_time
	ok = true
	return
}