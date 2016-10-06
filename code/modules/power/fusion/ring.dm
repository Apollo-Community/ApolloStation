//Four core corners (magnatic rings)
/obj/machinery/power/fusion/ring_corner
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/battery = 0
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring_corner"
	anchored = 0
	wired = 0
	panel_open = 1
	density = 1
	use_power = 0
	var/obj/item/weapon/tank/tank
	var/obj/item/weapon/neutronRod/rod
	var/obj/item/weapon/shieldCrystal/crystal
	origen = 0

/obj/machinery/power/fusion/ring_corner/New()
	//FOR DEBUG
	/*
	tank = new()
	rod = new()
	crystal = new()
	*/
	update_icon()
	..()

/obj/machinery/power/fusion/ring_corner/attackby(obj/item/W, mob/user)
	if(stat == BROKEN)
		..()

	if(istype(W, /obj/item/weapon/tank))
		if(src.tank)
			user << "<span class='alert'>There's already a phoron tank loaded.</span>"
			return 1
		user.drop_item()
		src.tank = W
		W.loc = src
		update_icon()
		return 1
	else if(istype(W, /obj/item/weapon/crowbar))
		var/obj/item/weapon/to_eject = input("What do you want to remove?") as null|anything in list(tank,rod,crystal)
		if(!to_eject)
			return
		if(to_eject == tank)
			eject_tank()
		if(to_eject == rod)
			eject_rod()
		if(to_eject == crystal)
			eject_crystal()
		update_icon()
		return
	if(istype(W, /obj/item/weapon/shieldCrystal))
		if(crystal)
			user << "<span class='alert'>There's already a field crystal installed.</span>"
			return 1
		user.drop_item()
		crystal = W
		W.loc = src
		update_icon()
		return
	if(istype(W, /obj/item/weapon/neutronRod))
		if(rod)
			user << "<span class='alert'>There's already an absorbtion rod installed.</span>"
			return 1
		user.drop_item()
		rod = W
		W.loc = src
		update_icon()

	..()

/obj/machinery/power/fusion/ring_corner/update_icon()
	//Some cheaty sneeky var updating here
	..()
	if(!wired || !anchored || isnull(crystal) || isnull(rod) || stat == BROKEN)
		ready = 0
	else
		ready = 1

/obj/machinery/power/fusion/ring_corner/proc/eject_tank()
	var/obj/item/weapon/tank/Z = src.tank
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.tank = null
	update_icon()

/obj/machinery/power/fusion/ring_corner/proc/eject_rod()
	if(check_lock())
		return
	var/obj/item/weapon/neutronRod/Z = src.rod
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.rod = null
	update_icon()

/obj/machinery/power/fusion/ring_corner/proc/eject_crystal()
	if(check_lock())
		return
	var/obj/item/weapon/shieldCrystal/Z = src.crystal
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.crystal = null
	update_icon()

/obj/machinery/power/fusion/ring_corner/proc/check_lock()
	if(locked)
		usr << "The component is magnetically locked in place."
		return 1
	return 0

/obj/machinery/power/fusion/ring_corner/proc/charge()
	if(stat == BROKEN)
		battery = 0
		return

	if(battery < 10000)
		use_power(600)
		battery = min(battery + 200, 10000)

//Returns the field energy produced by the ring.
/obj/machinery/power/fusion/ring_corner/proc/field_energy()
	if(stat == BROKEN)
		return 0

	if(battery > 150)
		battery -= 150
		return 150
	else
		return battery
		battery = 0

//Return content of tank inside, returns an empty gas mix if there is no or no gas mix in that tank.
/obj/machinery/power/fusion/ring_corner/proc/get_tank_content()
	if(isnull(tank))
		return new/datum/gas_mixture()
	if(isnull(tank.air_contents))
		return new/datum/gas_mixture()
	return tank.air_contents

//Set the content of the tank
/obj/machinery/power/fusion/ring_corner/proc/set_tank_content(var/datum/gas_mixture/gas)
	if(gas.temperature == 0)	//For some reason if I dont do this it turns the temp to 0.
		gas.temperature = 293.15
	tank.air_contents = gas

/obj/machinery/power/fusion/ring_corner/proc/get_tank_moles()
	if(isnull(tank))
		return 0
	if(isnull(tank.air_contents))
		return 0
	return tank.air_contents.total_moles

/obj/machinery/power/fusion/ring_corner/status()
	return "[(1000-damage)/10] %<br>"


/obj/machinery/power/fusion/ring_corner/proc/build_network(var/start, var/list/comp_list)
	if(src.origen == 1)
		//world.loop_checks=1
		src.in_network = 0
		src.origen = 0
		return comp_list
	comp_list += src
	in_network = 1

	//Find staight connection
	var/obj/machinery/power/fusion/ring/ring = null
	var/list/rings = list()
	rings += locate(/obj/machinery/power/fusion/ring) in get_step(src, src.dir)
	rings += locate(/obj/machinery/power/fusion/ring) in get_step(src, turn(src.dir, 90))
	rings += locate(/obj/machinery/power/fusion/ring) in get_step(src, turn(src.dir, 270))
	for(var/obj/machinery/power/fusion/ring/r in rings)
		if(!r.in_network)
			ring = r
			break
	if(isnull(ring))
		return list()

	ring.in_network = 1
	comp_list += ring
	ring = ring.get_pair()
	if(isnull(ring))
		return list()
	ring.in_network = 1
	comp_list += ring
	var/obj/machinery/power/fusion/ring_corner/rc = ring.get_corner()
	if(isnull(rc))
		return list()

	//We dont need to add the next corner sins it will add itself.

	//If you are the origen pass yourself as it. Else pass it allong
	if(start)
		src.origen = 1
	rc.build_network(0, comp_list)
	//When we return anywhere wee need to reset this.
	src.in_network = 0
	src.origen = 0

//8 edges of the magnetic ring
/obj/machinery/power/fusion/ring
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring"
	anchored = 0
	wired = 0
	panel_open = 1
	density = 1
	use_power = 0

/obj/machinery/power/fusion/ring/New()
	update_icon()
	..()

//Finds facing pair of containment ring (straight piece) checks and returns it.
//Returns null if not found or check failed.
/obj/machinery/power/fusion/ring/proc/get_pair()
	var/turf/t = get_turf(get_step(src, src.dir))
	var/max_range = 10
	var/range = 0
	while(range <= max_range)
		range += 1
		t = get_turf(get_step(t, src.dir))
		for(var/obj/machinery/power/fusion/ring/r in t.contents)
			if(istype(r, /obj/machinery/power/fusion/ring) && src.dir == turn(r.dir, 180)) //Are they facing each other ?
				return r
	return null

//Find connecting containment ring (corner piece)
/obj/machinery/power/fusion/ring/proc/get_corner()
	var/turf/t = get_turf(get_step(src, turn(src.dir, 180)))	//Get turf adacent from the pos its not facing.
	for(var/obj/machinery/power/fusion/ring_corner/rc in t.contents)
		if(istype(rc, /obj/machinery/power/fusion/ring_corner))
			if(turn(src.dir, 180) == turn(rc.dir, 90) || turn(src.dir, 180) == turn(rc.dir, 270) || src.dir == rc.dir )	//Are we facing either 90 deg away, 270 away or with the same dir.
				return rc
	return null

/obj/machinery/power/fusion/ring/proc/plasma_locs()
	var/turf/t = src
	var/list/locs = list()
	var/max_range = 10
	var/range = 0
	while(range <= max_range)
		range += 1
		t = get_step(t, src.dir)
		if(!istype(t, /turf))
			t = get_turf(t)
		for(var/obj/machinery/power/fusion/ring/r in t.contents)
			if(istype(r, /obj/machinery/power/fusion/ring) && src.dir == turn(r.dir, 180))
				return locs
		locs[t] = src.dir
	return null

/obj/machinery/power/fusion/ring/update_icon()
	..()
	if(!wired || !anchored || stat == BROKEN)
		ready = 0
	else
		ready = 1