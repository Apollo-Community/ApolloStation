/obj/machinery/rocket
	name = "rocket"
	desc = "You shouldn't see this, now stop it."
	anchored = 1.0
	density = 1.0
	var/ignited = 0

/obj/machinery/rocket/proc/ignite()
	ignited = 1

/obj/machinery/rocket/proc/deignite() // this is totally grammatically correct
	ignited = 0

/obj/machinery/rocket/cone
	name = "\improper Rocket Cone"
	icon = 'icons/obj/rocket_engine.dmi'
	icon_state = "cone"

/obj/machinery/rocket/cone/New()
	..()
	ignited = 1

/obj/machinery/rocket/cone/process()
	..()

/obj/machinery/rocket/flame
	name = "\improper flame"
	icon = 'icons/obj/rocket_engine_fire.dmi'
	icon_state = "flame"
	anchored = 1.0