obj/item/device/cable_painter
	name = "cable painter"
	desc = "A device for repainting cables."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/mode
	var/list/modes
	w_class = 2.0

obj/item/device/cable_painter/New()
	..()
	mode = COLOR_RED
	modes = new()
	modes["red"] = COLOR_RED
	modes["yellow"] = COLOR_YELLOW
	modes["green"] = COLOR_GREEN
	modes["blue"] = COLOR_BLUE
//	modes["pink"] = COLOR_PINK
//	modes["orange"] = COLOR_ORANGE
//	modes["cyan"] = COLOR_CYAN
//	modes["white"] = COLOR_WHITE
	mode = pick(modes)

obj/item/device/cable_painter/attack_self(mob/user)
	mode = input( "What color would you like to use?", "Choose a Color", null, null) in modes
	user << "<span class='notice'>You change the paint mode to [mode].</span>"
