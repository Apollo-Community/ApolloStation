/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id = null
	var/active = 0
	var/closed = 0
	var/secure = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/driver_button/secure
	name = "secure mass driver button"
	icon_state = "is_closed"
	desc = "A secure remote control switch for a mass driver."
	closed = 1
	secure = 1

/obj/machinery/driver_button/secure/north
	pixel_y = 32
	dir = SOUTH

/obj/machinery/driver_button/secure/south
	pixel_y = -32
	dir = NORTH

/obj/machinery/driver_button/secure/west
	pixel_x = -32
	dir = EAST

/obj/machinery/driver_button/secure/east
	pixel_x = 32
	dir = WEST

/obj/machinery/driver_button/secure/verb/toggle_open()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Button Glass"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"
		return
	if(active)
		usr << "<span class='warning'>It hasn't reset yet.</span>"
		return
	if(closed)
		closed = 0
		icon_state = "is_open"
	else
		closed = 1
		icon_state = "is_closed"
	playsound(src.loc, 'sound/machines/click.ogg', 3, 1, -3)

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(access_crematorium)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1