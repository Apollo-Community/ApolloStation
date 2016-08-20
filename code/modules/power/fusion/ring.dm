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