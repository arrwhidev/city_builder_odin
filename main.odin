package main

import "core:dynlib"
import "core:os"
import "core:fmt"
import vmem "core:mem/virtual"

// Allocate 4k (this is arbitrary)
MEM_SIZE :: 1024 * 1024 * 4 
Dll :: struct {
	init: proc(mem: []byte),
	close: proc(),
	update: proc(),
	running: proc() -> bool,
	hot_reload: proc(mem: rawptr),
	get_mem: proc() -> rawptr,
	get_mem_size: proc() -> int,
}

dll_last_load_time: os.File_Time
mem: []byte

main :: proc() {
	data, err := vmem.reserve_and_commit(MEM_SIZE)
	if err != nil {
		fmt.printfln("failed to reserve memory: {0}", err)
		os.exit(1)
	}
	mem = data
	defer vmem.release(&data, MEM_SIZE)

	dll, ok := load_dll()
	if !ok {
		fmt.printfln("failed to load game dll, exiting program")
		os.exit(1)
	}

	dll.init(data)
	for dll.running() {
		dll.update()

		new_dll, reloaded := maybe_reload_dll()
		if reloaded {
			new_mem_size := new_dll.get_mem_size()
			if new_mem_size != dll.get_mem_size() {
				fmt.println("mem size mismatch, hard resetting...")
				dll.close()
				new_dll.init(mem)
				dll = new_dll
			} else {
				fmt.println("mem size match, hot reloading...")
				old_mem := dll.get_mem()
				m := dll.get_mem()
				dll = new_dll
				new_dll.hot_reload(m)
			}
		}
	}
	dll.close()
}

maybe_reload_dll :: proc() -> (dll: Dll, reloaded: bool = false) {
	dll_path :: "out/game.dylib"
	dll_time, dll_time_err := os.last_write_time_by_name(dll_path)
	if dll_time_err != os.ERROR_NONE {
		// do not error just move on (this happens when dll has not finished rebuilding)
		fmt.eprintln("Could not fetch last write date of game.dll, error=", dll_time_err)
		return
	}

	if dll_time > dll_last_load_time {
		fmt.println("dll has changed, reloading...")
		return load_dll()
	}

	return 
}

load_dll :: proc() -> (dll: Dll, ok: bool = false) {
	dll_path :: "out/game.dylib"
	dll_time, dll_time_err := os.last_write_time_by_name(dll_path)

	if dll_time_err != os.ERROR_NONE {
		fmt.println("Could not fetch last write date of game.dll")
		return
  	}
	fmt.println("dll time checked successfully, lasted touched at:", dll_time)

	_, ok = dynlib.initialize_symbols(&dll, dll_path, "game_")
	if !ok {
		fmt.printfln("failed initializing symbols: {0}", dynlib.last_error())
		return
	}
	fmt.println("dll loaded successfully:", dll)

	if dll.init == nil || dll.update == nil || dll.close == nil || dll.running == nil || dll.hot_reload == nil || dll.get_mem == nil {
		fmt.println("Failed to init game api struct")
	}

	dll_last_load_time = dll_time
	ok = true
	return
}