//The fusion Tokamak <rjtwins>
/obj/machinery/power/fusion
	density = 1
	var/damage = 0
	var/wired = 0
	var/on = 0
	var/locked = 0
	emagged = 0
	var/ready = 0
	panel_open = 1
	var/datum/fusion_controller/fusion_controller
	anchored = 0
	var/in_network = 0
	var/origen = 0

//Explosions brake components
/obj/machinery/power/fusion/ex_act()
	stat = BROKEN
	desc = "[initial(desc)] It looks broken beyond repair."
	update_icon()

/*
/obj/machinery/power/fusion/emp_act(severity)
	stat = EMPED
	..(severity)
	update_icon()
*/

/obj/machinery/power/fusion/New()
	update_icon()
	..()

// Light up some sparks
/obj/machinery/power/fusion/proc/spark()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up( 3, 1, src )
	s.start()

//Just an interface
/obj/machinery/power/fusion/proc/status()
	update_icon()
	return

/obj/machinery/power/fusion/attackby(obj/item/W, mob/user)
	if(locked && stat == BROKEN)
		locked = 0
		on = 0
		update_icon()

	if(istype(W, /obj/item/weapon/wrench))
		if(locked)
			user << "The anchoring bolts are magnetically locked in place."
			return
		if(anchored)
			user << "You unanchor the bolts."
		else
			user << "You anchor the bolts."
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		anchored = !anchored
		on = 0
		update_icon()
		return 1

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(locked)
			user << "The access pannel is magnetically sealed"
			return
		if(panel_open)
			user << "You close the access pannel"
		else
			user << "You open the access panel"
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		update_icon()
		return

	else if(istype(W, /obj/item/stack/cable_coil) && panel_open && !wired)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 2)
			user << "<span class='alert'>You need more wires.</span>"
			return
		user << "You start adding cables to the Tokamak."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20) && C.amount >= 2)
			C.use(2)
			user.visible_message(\
				"<span class='alert'>[user.name] has added cables to the Tokamak!</span>",\
				"You add cables to the Tokamak.")
			wired = 1
		update_icon()
		return

	else if (istype(W, /obj/item/weapon/wirecutters) && panel_open && wired)
		user << "You begin to cut the cables..."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 50))
			new /obj/item/stack/cable_coil(loc,2)
			user.visible_message(\
				"<span class='alert'>[user.name] cut the cabling inside the Tokamak.</span>",\
				"You cut the cabling inside the Tokamak.")
			wired = 0
		update_icon()
		return

	else if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		user << "You hear a series of clicks as the main seals get disabled and auxilery ones take over."
		emagged = 1
		update_icon()
		return

	..()

//Rotation procs.
/obj/machinery/power/fusion/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.set_dir(turn(src.dir, 90))

/obj/machinery/power/fusion/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.set_dir(turn(src.dir, -90))

/obj/machinery/power/fusion/update_icon()
	if(stat == BROKEN)
		icon_state = "[initial(icon_state)]_broken"
		ready = 0
		return
	if(!panel_open && !on)
		icon_state = initial(icon_state)
		return
	if(panel_open && !wired)
		icon_state = "[initial(icon_state)]_open"
		return
	if(panel_open && wired)
		icon_state = "[initial(icon_state)]_wired"
		return
	if(on)
		icon_state = "[initial(icon_state)]_on"
		return

/obj/machinery/power/fusion/Destroy()
	if(!isnull(fusion_controller))
		fusion_controller.fusion_components -= src
	..()