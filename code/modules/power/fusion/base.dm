//The fusion Tokamak <rjtwins>
/obj/machinery/power/fusion
	density = 1
	var/damage = 0
	var/wired = 1
	var/on = 0
	var/locked = 0
	emagged = 0
	var/ready = 1
	panel_open = 0
	var/datum/fusion_controller/fusion_controller

/obj/machinery/power/fusion/New()
	update_icon()

/obj/machinery/power/fusion/proc/spark()
	// Light up some sparks
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up( 3, 1, src )
	s.start()

//Just an interface
/obj/machinery/power/fusion/proc/status()
	return

/obj/machinery/power/fusion/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(locked)
			user << "The anchoring bolts are magnetically locked in place."
			return
		if(anchored)
			user << "You unanchor the bolts."
		else
			user << "You anchor the bolts."
		anchored = !anchored
		on = 0
		update_icon()
		return

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(locked)
			user << "The acces pannel is magnetically sealed"
			return
		if(panel_open)
			user << "You close the acces pannel"
		else
			user << "You open the acces panel"
		panel_open = !panel_open
		update_icon()
		return

	else if(istype(W, /obj/item/stack/cable_coil) && panel_open && !wired)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 2)
			user << "<span class='alert'>You need more wires.</span>"
			return
		user << "You start adding cables to the ring"
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20) && C.amount >= 2)
			C.use(2)
			user.visible_message(\
				"<span class='alert'>[user.name] has added cables to the panel!</span>",\
				"You add cables to the panel.")
			wired = 1
			update_icon()
		return

	else if (istype(W, /obj/item/weapon/wirecutters) && panel_open && wired)
		user << "You begin to cut the cables..."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 50))
			new /obj/item/stack/cable_coil(loc,2)
			user.visible_message(\
				"<span class='alert'>[user.name] cut the cabling inside the panel.</span>",\
				"You cut the cabling inside the panel.")
			update_icon()
			wired = 0
		return
	else if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		user << "You hear a click disabling the magnetic seals."
		emagged = 1
		update_icon()
		return
		..()

/obj/machinery/power/fusion/update_icon()
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