#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it! 
#endif

/obj/item/weapon/circuitboard/teleporterstation
	name = T_BOARD("teleporter station")
	build_path = "/obj/machinery/teleport/station"
	board_type = "machine"
	origin_tech = "programming=5;engineering=5"
	frame_desc = "Requires 1 Subspace Transmitter,2 Manipulator, 2 Scanning Module and 2 pieces of cable."
	req_components = list(
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1)

/obj/item/weapon/circuitboard/teleporterhub
  name = T_BOARD("Teleporter Hub")
  build_path = "/obj/machinery/teleport/hub"
  board_type = "machine"
  origin_tech = "enginering=5,bluespace=4"
  frame_desc = "Requires 1 Ansible Crystal, 2 Subspace Transmitter and 2 pieces of cable."
  req_components = list(
                  "/obj/item/weapon/stock_parts/subspace/transmitter" = 2,
                  "/obj/item/stack/cable_coil" = 2,
                  "/obj/item/weapon/stock_parts/subspace/crystal" = 1)
