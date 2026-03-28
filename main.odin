package main

import "core:dynlib"
import "core:os"
import "core:fmt"
import vmem "core:mem/virtual"

// The entire game's permanent memory lives in one contiguous block.
// 4MB is arbitrary — will increase if the arena overflows at runtime.
MEM_SIZE :: 1024 * 1024 * 4

// Dll mirrors the exported symbols from the game DLL. 
// Main communicates with the game via this interface so that the DLL
// can be swapped at runtime without restarting the process (hot reload).
Dll :: struct {
	// Called once at startup (or after hard reset). Receives the raw memory
	// block so the DLL can set up its arena allocator inside it.
	init: proc(mem: []byte),
	close: proc(),
	update: proc(),
	running: proc() -> bool,

	// Called after a hot reload when GameMemory layout has NOT changed.
	// The DLL updates its internal g_mem pointer to point at the live data.
	hot_reload: proc(mem: rawptr),
	
	// Returns a pointer to GameMemory, which lives inside the memory block.
	get_mem: proc() -> rawptr,
	
	// Returns size_of(GameMemory) so we can detect layout changes between reloads.
	get_mem_size: proc() -> int,
}

// Actual variable holding real game memory.
mem: []byte
dll_last_load_time: os.File_Time

main :: proc() {
	// Reserve and commit the full block upfront. This memory is owned by main
	// for the entire process lifetime — the DLL never frees it, only reads/writes it.
	// Keeping memory ownership in main means it survives DLL unload/reload.
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

	// init carves GameMemory out of the front of the block using an arena
	// allocator, then stores the arena inside GameMemory for future allocations.
	dll.init(data)
	for dll.running() {
		dll.update()

		new_dll, reloaded := maybe_reload_dll()
		if reloaded {
			new_mem_size := new_dll.get_mem_size()
			if new_mem_size != dll.get_mem_size() {
				// GameMemory layout changed (fields added/removed/reordered).
				// We can't safely reinterpret the old bytes, so hard reset:
				// close the window, re-init from scratch using the same memory block.
				fmt.println("mem size mismatch, hard resetting...")
				dll.close()
				new_dll.init(mem)
				dll = new_dll
			} else {
				// Layout is identical — the new DLL can safely reinterpret the
				// existing bytes. Just hand it the live pointer and continue.
				// Game state (position, health, etc.) is preserved across the reload.
				fmt.println("mem size match, hot reloading...")
				old_mem := dll.get_mem()
				m := dll.get_mem()
				dll = new_dll
				new_dll.hot_reload(m)
				_ = old_mem
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

	// Populate the Dll struct by scanning the dylib for symbols prefixed "game_"
	// e.g. game_init -> dll.init, game_update -> dll.update, etc.
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
