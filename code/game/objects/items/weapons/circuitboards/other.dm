#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

//Stuff that doesn't fit into any category goes here

/obj/item/weapon/circuitboard/aicore
	name = T_BOARD("AI core")
	origin_tech = "programming=4;biotech=2"
	board_type = "other"

obj/item/weapon/circuitboard/fax_machine
	name = T_BOARD("fax machine")
	build_path = "/obj/machinery/photocopier/fax_machine"
	board_type = "machine"
	origin_tech = "programming=2, bluespace=2"
	frame_desc = "Requires 1 Micro-Manipulator, 1 Light Tube, 1 Subspace Transmitter, 1 Subspace Amplifier, and 1 Scanning Module."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/light/tube" = 1,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

obj/item/weapon/circuitboard/photocopier
	name = T_BOARD("photocopier")
	build_path = "/obj/machinery/photocopier"
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 1 Micro-Manipulator, 1 Light Tube, and 1 Scanning Module."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/light/tube" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)