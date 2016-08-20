//The fusion Tokamak <rjtwins>
/obj/machinery/power/fusion
	density = 1
	var/damage = 0
	var/wired = 0
	var/on = 0
	var/open_panel = 0
	var/locked = 0
	emagged = 0

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

	else if(istype(W, /obj/item/weapon/screwdriver) && !locked)
		if(!locked)
			user << "The acces pannel is magnetically sealed"
			return
		open_panel = 1
		update_icon()

	else if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		user << "You hear a click disabling the magnetic seals."
		emagged = 1
		update_icon()

/obj/machinery/power/fusion/update_icon()
	if(!open_panel && !on)
		icon_state = initial(icon_state)
		return
	if(open_panel && !wired)
		icon_state = "[initial(icon_state)]_open"
		return
	if(open_panel && wired)
		icon_state = "[initial(icon_state)]_wired"
		return
	if(on)
		icon_state = "[initial(icon_state)]_on"
		return