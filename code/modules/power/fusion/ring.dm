//Four core corners (magnatic rings)
/obj/machinery/power/fusion/ring_corner
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/battery = 0
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring_corner"
	anchored = 1
	wired = 1
	panel_open = 0
	density = 1
	use_power = 0
	var/obj/item/weapon/tank/hydrogen/tank
	var/obj/item/weapon/neutronRod/rod
	var/obj/item/weapon/shieldCrystal/crystal

/obj/machinery/power/fusion/ring_corner/New()
	//FOR DEBUG
	tank = new()
	rod = new()
	crystal = new()
	update_icon()
	..()

/obj/machinery/power/fusion/ring_corner/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/tank/hydrogen))
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
	if(!wired || !anchored || isnull(crystal) || isnull(rod))
		ready = 0
	else
		ready = 1

/obj/machinery/power/fusion/ring_corner/proc/eject_tank()
	var/obj/item/weapon/tank/hydrogen/Z = src.tank
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
	if(battery < 10000)
		use_power(600)
		battery = min(battery + 200, 10000)

//Returns the field energy produced by the ring.
/obj/machinery/power/fusion/ring_corner/proc/field_energy()
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
	//world << "gas moles in set_tank_contents [gas.total_moles]"
	if(gas.temperature == 0)	//For some reason if I dont do this it turns the temp to 0.
		gas.temperature = 293.15
	tank.air_contents = gas
	//world << "gas moles in tank afther set_tank_contents [tank.air_contents.total_moles]"

/obj/machinery/power/fusion/ring_corner/proc/get_tank_moles()
	if(isnull(tank))
		return 0
	if(isnull(tank.air_contents))
		return 0
	return tank.air_contents.total_moles

/obj/machinery/power/fusion/ring_corner/status()
	return "[(1000-damage)/10] %<br>"

//8 edges of the magnetic ring
/obj/machinery/power/fusion/ring
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring"
	anchored = 1
	wired = 1
	panel_open = 0
	density = 1
	use_power = 0

/obj/machinery/power/fusion/ring/New()
	update_icon()
	..()

/obj/machinery/power/fusion/ring/update_icon()
	..()
	if(!wired || !anchored)
		ready = 0
	else
		ready = 1