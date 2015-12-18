/obj/machinery/broodswarm
	anchored = 1
	density = 1
	opacity = 0

	use_power = 0
	interact_offline = 1

/obj/machinery/broodswarm/New()
	..()

	if( !ticker.addToHive( src ))
		qdel( src )

/obj/machinery/broodswarm/Destroy()
	ticker.removeFromHive( src )

	..()

/obj/machinery/broodswarm/emp_act(severity)
	return

/obj/machinery/broodswam/large
	name = "broodswarm hive structure"
	desc = "A disgusting strcuture of flesh."
	icon = 'icons/obj/broodswarm_hive.dmi'
	pixel_x = -16

