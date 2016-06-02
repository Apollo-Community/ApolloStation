/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = 4.0
	canhear_range = 2
	flags = CONDUCT | NOBLOODY
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	var/buildstage = 0
	var/panel_open = 0

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

/obj/item/device/radio/intercom/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(buildstage == 2)
			default_deconstruction_screwdriver(user,"intercom_frame_wired","intercom",I)
		else
			user << "There is no panel to open or close yet."
		return

	if(panel_open == 1)
		switch(buildstage)
			if(2)
				if(istype(I, /obj/item/weapon/crowbar))
					user << "You pry out the signaler!"
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					spawn(1)
						var/obj/item/weapon/intercom_electronics/S = new /obj/item/weapon/intercom_electronics()
						S.loc = user.loc
						buildstage = 1

			if(1)
				if (istype(I, /obj/item/weapon/wirecutters))
					user.visible_message("<span class='alert'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					icon_state = "access_button_frame"
					spawn(1)
						var/obj/item/stack/cable_coil/S = new /obj/item/stack/cable_coil()
						S.amount = 1
						S.icon_state = "coil1"
						S.loc = user.loc
						buildstage = 0

				else if(istype(I, /obj/item/weapon/intercom_electronics))
					qdel(I)
					user.visible_message("<span class='alert'>[user] You put the signaler inside \the [src] finishing it.</span>", "You put the signaler inside \the [src] finishing it.")
					buildstage = 2
			if(0)
				if(istype(I, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = I
					if (C.use(2))
						user << "<span class='notice'>You wire \the [src].</span>"
						buildstage = 1
						return
					else
						user << "<span class='warning'>You need 2 pieces of cable to do wire \the [src].</span>"
						return
				if(istype(I, /obj/item/weapon/wrench))
					user << "You remove the fire alarm assembly from the wall!"
					var/obj/item/intercom_frame/frame = new /obj/item/intercom_frame()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)

		update_icon()
		return
	..()

/obj/item/device/radio/intercom/update_icon()
	switch(buildstage)
		if(0)
			icon_state = "intercom_frame"
		if(1)
			icon_state = "intercom_frame_wired"
		if(2)
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

/obj/item/intercom_frame/proc/try_build(turf/on_wall)
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


//Some helper procs
/obj/item/device/radio/intercom/proc/default_deconstruction_screwdriver(var/mob/user, var/icon_state_open, var/icon_state_closed, var/obj/item/weapon/screwdriver/S)
	if(istype(S))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = icon_state_closed
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return 1
	return 0