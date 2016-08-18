//The fusion Tokamak <rjtwins>
/obj/machinery/power/fusion
	density = 1
	var/damage = 0

/obj/machinery/power/fusion/proc/spark()
	// Light up some sparks
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up( 3, 1, src )
	s.start()

//Just an interface
/obj/machinery/power/fusion/proc/status()
	return

/obj/machinery/power/fusion/attackby()
	return