//////////////////////////////////////
// Toakamk Control computer

/obj/item/weapon/circuitboard/tokamak_control_console
	name = "Circuit board (Tokamak control console)"
	build_path = "/obj/machinery/computer/fusion"
	origin_tech = "programming=4;engineering=4"

datum/design/tokamak_control_console
	name = "Circuit Design (Tokamak control console)"
	desc = "Allows for the construction of circuit boards used to build a core control console for the Tokamak fusion engine."
	id = "tokamak_control_console"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = "/obj/item/weapon/circuitboard/tokamak_control_console"

//////////////////////////////////////
// Toakamk coponents fab.

/obj/item/weapon/circuitboard/tokamak_comp_fab
	name = "Internal circuitry (Tokamak Component Fabricator)"
	build_path = "/obj/machinery/tokamakFabricator"
	board_type = "machine"
	origin_tech = "phorontech=2;magnets=4;powerstorage=2"
	frame_desc = "Requires 1 Pico Manipulators, 1 Ultra Micro-Laser, 5 Pieces of Cable and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 1,
							"/obj/item/weapon/stock_parts/micro_laser/ultra" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)