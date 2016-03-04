/*--      THOU HAV BEEN WARNED KNAVE       --*/
/*--   FORE HERE THERE ARE MANY EVIL BUGS  --*/
/*--      ENTER ON THINE OWNE ACCORDE      --*/
/*-- Feel free to checkout our gift store! --*/ //>:^#)

obj/item/device/cable_painter
	name = "cable painter"
	desc = "A device for repainting laid cables."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	var/list/modes
	var/mode
	w_class = 2.0

obj/item/device/cable_painter/New()
	..()
	modes["red"] = COLOR_RED
	modes["yellow"] = COLOR_YELLOW
	modes["green"] = COLOR_GREEN
	modes["blue"] = COLOR_BLUE
	modes["pink"] = COLOR_PINK
	modes["orange"] = COLOR_ORANGE
	modes["cyan"] = COLOR_CYAN
	modes["white"] = COLOR_WHITE
	mode = pick(modes)

obj/item/device/cable_painter/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return

	if(!istype(A,/obj/structure/cable))
		return
	var/obj/structure/cable/C = A

	var/turf/T = C.loc
	if (C.level < 2 && T.level==1 && isturf(T) && T.intact)
		user << "<span class='alert'>You must remove the plating first.</span>"
		return

	C.color = modes[mode]


obj/item/device/cable_painter/attack_self(mob/user)
	mode = input( "What color would you like to use?", "Choose a Color", null, null) in modes
	user << "<span class='notice'>You change the paint mode to [mode].</span>"
