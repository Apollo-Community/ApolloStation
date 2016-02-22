/obj/machinery/computer/transfer
	name = "\improper job transfer console"
	desc = "Terminal for handling job transfer. Any employee can use this to switch to a role they already have been promoted to."
	icon_state = "id"

	circuit = "/obj/item/weapon/circuitboard/transfer"
	var/obj/item/weapon/card/id/scan = null

	light_color = COMPUTER_BLUE