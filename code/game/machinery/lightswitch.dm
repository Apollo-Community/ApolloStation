// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/on = 1
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1

/obj/machinery/light_switch/New(loc, dir, building)
	..()
	if(loc)
		src.loc = loc

	if(dir)
		src.set_dir(dir)

	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -27 : 27) : 0

	spawn(5)
		src.area = get_area(src)

		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		if(!name)
			name = "light switch ([area.name])"

		src.on = src.area.lightswitch
		updateicon()

/obj/machinery/light_switch_construct //For building a lightswitch
	name = "light switch frame"
	desc = "A light switch under construction."
	icon = 'icons/obj/power.dmi'
	icon_state = "light-p"
	anchored = 1
	var/stage = 1

/obj/machinery/light_switch_construct/New(loc, dir, building)
	..()

	if(loc)
		src.loc = loc

	if(dir)
		src.set_dir(dir)

	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -27 : 27) : 0

/obj/machinery/light_switch_construct/examine(mob/user)
	if(!..(user, 2))
		return

	switch(src.stage)
		if(1)
			user << "It's an empty frame."
			return
		if(2)
			user << "It's wired."
			return

/obj/machinery/light_switch_construct/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (istype(W, /obj/item/weapon/wrench))
		if (src.stage == 1)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			usr << "You begin deconstructing [src]."
			if (!do_after(usr, 30))
				return
			new /obj/item/stack/sheet/metal( get_turf(src.loc) )
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
			qdel(src)
		if (src.stage == 2)
			usr << "You have to remove the wires first."
			return

		if (src.stage == 3)
			usr << "You have to unscrew the case first."
			return

	if(istype(W, /obj/item/weapon/wirecutters))
		if (src.stage != 2) return
		src.stage = 1
		src.icon_state = "light-p"
		new /obj/item/stack/cable_coil(get_turf(src.loc), 1, "red")
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return

	if(istype(W, /obj/item/stack/cable_coil))
		if (src.stage != 1) return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			src.icon_state = "light-w"
			src.stage = 2
			user.visible_message("[user.name] adds wires to [src].", \
				"You add wires to [src].")
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if (src.stage == 2)
			src.icon_state = "light-p"
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			var/obj/machinery/light_switch/newswitch = new /obj/machinery/light_switch(src.loc, dir, 1)
			src.transfer_fingerprints_to(newswitch)
			qdel(src)

/obj/machinery/light_switch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
		user.visible_message("[user.name] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
		var/obj/machinery/light_switch_construct/newswitch = new /obj/machinery/light_switch_construct(src.loc, dir, 1)
		newswitch.stage = 2
		newswitch.icon_state = "light-w"
		src.transfer_fingerprints_to(newswitch)
		qdel(src)
		return

/obj/machinery/light_switch/proc/updateicon()
	if(stat & NOPOWER)
		icon_state = "light-p"
	else
		icon_state = "light[on]"

/obj/machinery/light_switch/examine(mob/user)
	if(..(user, 1))
		user << "A light switch. It is [on? "on" : "off"]."

/obj/machinery/light_switch/attack_hand(mob/user)

	on = !on

	area.lightswitch = on
	area.updateicon()

	for(var/obj/machinery/light_switch/L in area)
		L.on = on
		L.updateicon()

	area.power_change()

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(LIGHT))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

		updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)