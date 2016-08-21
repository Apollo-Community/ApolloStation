//Four core corners (magnatic rings)
/obj/machinery/power/fusion/ring_corner
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/battery = 0
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring_corner"
	anchored = 1
	density = 1
	use_power = 0
	var/obj/item/weapon/tank/hydrogen/tank
	var/obj/item/weapon/neutronRod/rod
	var/obj/item/weapon/shieldCrystal/crystal

/obj/machinery/power/fusion/ring_corner/New()
	..()
	//FOR DEBUG
	tank = new()
	rod = new()
	crystal = new()

/obj/machinery/power/fusion/ring_corner/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/tank/hydrogen))
		if(src.tank)
			user << "<span class='alert'>There's already a phoron tank loaded.</span>"
			return 1
		user.drop_item()
		src.tank = W
		W.loc = src
		return 1
	else if(istype(W, /obj/item/weapon/crowbar))
		var/obj/item/weapon/to_eject = input("What item do you want to remove?","Remove?","") in list(tank, rod, crystal)
		if(to_eject)
			eject(to_eject)
			return 1
	if(istype(W, /obj/item/weapon/shieldCrystal))
		if(crystal)
			user << "<span class='alert'>There's already a field crystal installed.</span>"
			return 1
		user.drop_item()
		crystal = W
		W.loc = src

	if(istype(W, /obj/item/weapon/neutronRod))
		if(rod)
			user << "<span class='alert'>There's already an absorbtion rod installed.</span>"
			return 1
		user.drop_item()
		rod = W
		W.loc = src

	..()

/obj/machinery/power/fusion/ring_corner/update_icon()
	//Some cheaty sneeky var updating here
	if(!panel_open || !wired || !anchored || isnull(crystal) || isnull(rod))
		ready = 0
	else
		ready = 1
	..()

/obj/machinery/power/fusion/ring_corner/proc/eject(obj/item/weapon/to_eject)
	if(isnull(to_eject))
		return
	var/obj/Z
	if(istype(to_eject, /obj/item/weapon/tank/phoron))
		Z = src.tank
		src.tank = null

	if(istype(to_eject, /obj/item/weapon/tank/phoron))
		Z = src.rod
		src.rod = null

	if(istype(to_eject, /obj/item/weapon/tank/phoron))
		Z = src.crystal
		src.crystal = null

	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)

//Override to make sure the icon does not dissapear
/obj/machinery/power/fusion/ring_corner/update_icon()
	return

/obj/machinery/power/fusion/ring_corner/proc/get_tank_content()
	return tank.air_contents

/obj/machinery/power/fusion/ring_corner/proc/set_tank_content(var/datum/gas_mixture/gas)
	tank.air_contents = gas

/obj/machinery/power/fusion/ring_corner/proc/get_tank_moles()
	return tank.air_contents.total_moles

/obj/machinery/power/fusion/ring_corner/status()
	return "Capacitor: [battery] <br>Integrity: [(1000-damage)/10] %<br>"

//8 edges of the magnetic ring
/obj/machinery/power/fusion/ring
	name = "Fusion Containment Ring"
	desc = "Part of the fusion containment ring keeps hot fusion from escaping."
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring"
	anchored = 1
	density = 1
	use_power = 0