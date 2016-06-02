/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	base_name = "intercom"
	anchored = 1
	w_class = 4.0
	canhear_range = 2
	flags = CONDUCT | NOBLOODY
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	buildstage = 2
	panel_open = 0
	on = 0

/obj/item/device/radio/intercom/New(loc, dir, building)
	..()
	processing_objects += src
	if(loc)
		src.loc = loc

	if(dir)
		src.set_dir(dir)

	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
	update_icon()

/obj/item/device/radio/intercom/Destroy()
	processing_objects -= src
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_self(mob/user as mob)
	if(panel_open || buildstage != 2)
		user << "You must close the panel before you can interact with the intercom."
		return
	..()

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq in ANTAG_FREQS)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/hear_talk(mob/M as mob, msg)
	if(!src.anyai && !(M in src.ai))
		return
	..()

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday
		if(buildstage != 2)
			update_icon()
			return
		if(panel_open)
			on = 0

		if(!src.loc)
			on = 0
		else
			var/area/A = src.loc.loc
			if(!A || !isarea(A))
				on = 0
			else
				on = A.powered(EQUIP) // set "on" to the power status
		if(!on)
			icon_state = "intercom-p"
		else
			icon_state = "intercom"

		if(panel_open)
			icon_state = "intercom_frame_wired"

/obj/item/device/radio/intercom/attackby(obj/item/I as obj, mob/user as mob)
	if (attackby_construction(I ,user, "intercom"))
		return
	..()

/obj/item/device/radio/intercom/update_icon()
	switch(buildstage)
		if(0)
			icon_state = "intercom_frame"
		if(1)
			icon_state = "intercom_frame_wired"
		if(2)
			if(panel_open)
				icon_state = "intercom_frame_wired"

/*
INTERCOM FRAME ITEM
Handheld intercom frame, for placing on walls
Code shamelessly copied from firealarm_frame
*/
/obj/item/intercom_frame
	name = "Intercom Frame"
	desc = "Used for building Intercoms"
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom_frame"
	flags = CONDUCT

/obj/item/intercom_frame/attack(var/M as mob|turf, mob/living/user as mob, def_zone)
	if(try_build(M))
		return
	..(M, user, def_zone)

/obj/item/intercom_frame/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)

	if(gotwallitem(loc, ndir))
		usr << "<span class='alert'>There's already an item on this wall!</span>"
		return

	var/obj/item/device/radio/intercom/M = new /obj/item/device/radio/intercom(loc, ndir, 1)
	M.panel_open = 1
	M.buildstage = 0
	M.update_build_icon()
	qdel(src)

	return 1


/*
INTERCOM CIRCUIT
Just a object used in constructing air alarms
*/
/obj/item/weapon/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	desc = "Looks like a circuit. Probably is."
	w_class = 2.0
	matter = list("metal" = 50, "glass" = 50)