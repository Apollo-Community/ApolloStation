#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/weapon/circuitboard/papershredder
	name = T_BOARD("paper shredder")
	build_path = "/obj/machinery/papershredder"
	board_type = "machine"
	origin_tech = "engineering = 3"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)