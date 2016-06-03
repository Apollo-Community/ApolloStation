/obj/structure/door_assembly/rc_blast_door
	name = "blast door assembly"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	anchored = 0
	density = 1
	base_icon_state = ""
	base_name = "Blast door"
	created_name = null

	New()
		update_state()

/obj/structure/door_assembly/rc_blast_door/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		var/t = sanitizeSafe(input(user, "Enter the name for the door.", src.name, src.created_name), MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (!WT.isOn())
			return
		if (WT.remove_fuel(0, user))
			if(!anchored)
				user.visible_message("[user] dissassembles the blast door assembly.", "You start to dissassemble the blast door assembly.")
				if(do_after(user, 40))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user << "<span class='notice'>You dissasembled the airlock assembly!</span>"
					new /obj/item/stack/sheet/metal(src.loc, 20)
					qdel (src)
			else if(src.state == 4)
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				new /obj/machinery/door/blast/rc/regular(src.loc)
				qdel(src)
		else
			user << "<span class='notice'>You need more welding fuel.</span>"
			return

	else if(istype(W, /obj/item/weapon/wrench) && state == 0)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		if(anchored)
			user.visible_message("[user] unsecures the blast door assembly from the floor.", "You start to unsecure the blast door assembly from the floor.")
		else
			user.visible_message("[user] secures the blast door assembly to the floor.", "You start to secure the blast door assembly to the floor.")

		if(do_after(user, 40))
			if(!src) return
			user << "<span class='notice'>You [anchored? "un" : ""]secured the blast door assembly!</span>"
			anchored = !anchored

	else if(istype(W, /obj/item/stack/cable_coil) && state == 0 && anchored)
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			user << "<span class='warning'>You need one length of coil to wire the blast door assembly.</span>"
			return
		user.visible_message("[user] wires the blast door assembly.", "You start to wire the blast door assembly.")
		if(do_after(user, 40) && state == 0 && anchored)
			if (C.use(1))
				src.state = 1
				user << "<span class='notice'>You wire the airlock.</span>"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the blast door assembly.", "You start to cut the wires from blast door assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "<span class='notice'>You cut the blast door wires.!</span>"
			new/obj/item/stack/cable_coil(src.loc, 1)
			src.state = 0

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the blast door assembly.", "You start to install electronics into the blast door assembly.")

		if(do_after(user, 40))
			if(!src) return
			user.drop_item()
			W.loc = src
			user << "<span class='notice'>You installed the airlock electronics!</span>"
			src.state = 2
			src.name = "Near finished blast door Assembly"
			src.electronics = W

	else if(istype(W, /obj/item/weapon/crowbar))
		//This should never happen, but just in case I guess
		if (state == 2 && !electronics)
			user << "<span class='notice'>There was nothing to remove.</span>"
			src.state = 1
			return
		else if(state == 4)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user << "<span class='notice'>You wedge the reinforcec pieces free of the blast door assembly.</span>"
			new /obj/item/stack/sheet/alloy/plasteel(src.loc, 20)


		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the blast door assembly.", "You start to remove the electronics from the blast door assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "<span class='notice'>You removed the airlock electronics!</span>"
			src.state = 1
			src.name = "Wired blast door Assembly"
			electronics.loc = src.loc
			electronics = null

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user << "<span class='notice'>Now finishing the blast door.</span>"

		if(do_after(user, 40))
			if(!src) return
			user << "<span class='notice'>You screw the airlock electronics in place</span>"
			src.state = 3

	else if(istype(W, /obj/item/stack/sheet/alloy/plasteel) && src.state == 3)
		var/obj/item/stack/sheet/alloy/plasteel/S = W
		if (S.get_amount() >= 15)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] adds [S.name] to the blast door assembly.", "You start to install [S.name] into the blast door assembly.")
			if(do_after(user, 40))
				if (S.use(15))
					user << "<span class='notice'>You installed reinforced plating on the blast door assembly.</span>"
					src.state = 4
	else
		..()
	update_state()

/obj/structure/door_assembly/rc_blast_door/update_state()
	switch(src.state)
		if(1)
			icon_state = "pdoor1"
			name = "Wired blast door assembly."
		if(2)
			icon_state = "pdoor1"
			name = "Wired blast door assembly with unsecured electronics."
		if(3)
			icon_state = "pdoor1"
			name = "Unarmored blast door assembly."
		if(4)
			icon_state = "pdoor1"
			name = "Armored unwelded blast door assembly."
