obj/machinery/radio_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "radio signal button"

	anchored = 1
	power_channel = ENVIRON

	var/code = 30
	var/frequency = 1457
	var/master_tag
	var/command = "cycle"
	var/datum/radio_frequency/radio_connection
	var/on = 1
	var/buildstage = 0
	panel_open = 1
	icon_state = "access_button_frame"

obj/machinery/radio_button/initialize()
	set_frequency(frequency)

obj/machinery/radio_button/New(loc, dir, building)
	..()

	if(loc)
		src.loc = loc

	if(dir)
		src.set_dir(dir)

	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

obj/machinery/radio_button/update_icon()
	if(on)
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

obj/machinery/radio_button/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/multitool))
		var/new_freq = input("Set button signal frequentie", "Button frequentie", frequency) as num|null
		var/new_code = input("Set button signal code", "Signal code", code) as num|null
		if(new_freq != frequency)
			set_frequency(new_freq)
		if(new_code != code)
			set_code(new_code)
		return

	//Swiping ID on the access button
	if (istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
		attack_hand(user)
		return

	if(istype(I, /obj/item/weapon/screwdriver))
		if(buildstage == 1 || buildstage == 2)
			default_deconstruction_screwdriver(user,"access_button_frame_wired","access_button_standby",I)
		else if (buildstage == 0)
			default_deconstruction_screwdriver(user,"access_button_frame","access_button_standby",I)
		return

	if(panel_open == 1)
		switch(buildstage)
			if(2)
				if(istype(I, /obj/item/weapon/crowbar))
					user << "You pry out the signaler!"
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					spawn(1)
						var/obj/item/device/assembly/signaler/S = new /obj/item/device/assembly/signaler()
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

				else if(istype(I, /obj/item/device/assembly/signaler))
					var/obj/item/device/assembly/signaler/S = I
					code = S.code
					frequency = S.frequency
					qdel(I)
					user.visible_message("<span class='alert'>[user] You put the signaler inside \the [src] finishing it.</span>", "You put the signaler inside \the [src] finishing it.")
					if(radio_controller)
						set_frequency(frequency)
					icon_state = "access_button_frame_wired"
					buildstage = 2
			if(0)
				if(istype(I, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = I
					if (C.use(1))
						user << "<span class='notice'>You wire \the [src].</span>"
						buildstage = 1
						icon_state = "access_button_frame_wired"
						return
					else
						user << "<span class='warning'>You need 1 pieces of cable to do wire \the [src].</span>"
						return
				if(istype(I, /obj/item/weapon/wrench))
					user << "You remove the fire alarm assembly from the wall!"
					var/obj/item/radio_button_frame/frame = new /obj/item/radio_button_frame()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return
	..()

obj/machinery/radio_button/attack_hand(mob/user)
	if(panel_open) //Panel is open you cannot interact.
		user << "Close the panel first"
		return
	if(buildstage != 2) //The button is not finished yet finish it first.
		user << "Finish its construction first."
		return
	add_fingerprint(usr)
	if(!allowed(user))
		user << "<span class='alert'>Access Denied</span>"

	else if(radio_connection)
		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code
		signal.data["message"] = "ACTIVATE"
		radio_connection.post_signal(src, signal)
	flick("access_button_cycle", src)

obj/machinery/radio_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

obj/machinery/radio_button/proc/set_code(var/new_code = 30)
	code = new_code

obj/machinery/radio_button/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	..()

/*
RADIO BUTTON FRAME ITEM
Handheld radio button, for placing on walls
Code shamelessly copied from firealarm_frame
*/
/obj/item/radio_button_frame
	name = "radio button frame"
	desc = "Used for building radio buttons"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_frame"
	flags = CONDUCT

/obj/item/radio_button_frame/attack(var/M as mob|turf, mob/living/user as mob, def_zone)
	if(try_build(M))
		return
	..(M, user, def_zone)

/obj/item/radio_button_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)

	if(gotwallitem(loc, ndir))
		usr << "<span class='alert'>There's already an item on this wall!</span>"
		return

	new /obj/machinery/radio_button(loc, ndir, 1)

	qdel(src)

	return 1