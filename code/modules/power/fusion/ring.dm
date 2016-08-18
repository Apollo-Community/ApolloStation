//Four core corners (magnatic rings)
/obj/machinery/power/fusion/ring_corner
	var/battery = 100
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "diagonalWall"
	anchored = 1
	density = 1
	use_power = 0
	var/obj/item/weapon/tank/phoron/tank = null

/obj/machinery/power/fusion/ring_corner/New()
	..()
	tank = new()

/obj/machinery/power/fusion/ring_corner/proc/get_tank_content()
	return tank.air_contents

/obj/machinery/power/fusion/ring_corner/proc/get_tank_moles()
	return tank.air_contents.total_moles

/obj/machinery/power/fusion/ring_corner/status()
	return "Capacitor: [battery] <br>Integrity: [(1000-damage)/10] %<br>"

//8 edges of the magnetic ring
/obj/machinery/power/fusion/ring
	var/integrity = 1000
	icon = 'icons/obj/fusion.dmi'
	icon_state = "ring"
	anchored = 1
	density = 1
	use_power = 0