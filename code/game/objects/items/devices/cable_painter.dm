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
	modes[0] = COLOR_RED
	modes[1] = COLOR_YELLOW
	modes[2] = COLOR_GREEN
	modes[3] = COLOR_BLUE
	modes[4] = COLOR_PINK
	modes[5] = COLOR_ORANGE
	modes[6] = COLOR_CYAN
	modes[7] = COLOR_WHITE
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
	if(mode == 7)
		mode = 0

	else
		mode++

	user << "<span class='notice'>You change the paint mode.</span>"
