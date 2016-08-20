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
	var/obj/item/weapon/tank/phoron/tank = null

/obj/machinery/power/fusion/ring_corner/New()
	..()
	tank = new()

/obj/machinery/power/fusion/ring_corner/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/tank/phoron))
		if(!src.anchored)
			user << "<span class='alert'>The [src] needs to be secured to the floor first.</span>"
			return 1
		if(src.tank)
			user << "<span class='alert'>There's already a phoron tank loaded.</span>"
			return 1
		user.drop_item()
		src.tank = W
		W.loc = src
		return 1
	else if(istype(W, /obj/item/weapon/crowbar))
		if(tank)
			eject()
			return 1

/obj/machinery/power/fusion/ring_corner/proc/eject()
	var/obj/item/weapon/tank/phoron/Z = src.tank
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.tank = null

//Override to make sure the icon does not dissapear
/obj/machinery/power/fusion/ring_corner/update_icon()
	return

/obj/machinery/power/fusion/ring_corner/proc/get_tank_content()
	return tank.air_contents

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