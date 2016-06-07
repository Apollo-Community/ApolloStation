/datum/event/electrical_storm

/datum/event/electrical_storm/announce()
	command_announcement.Announce("It has come to our attention that the station passed through an ion storm. Engineering personnel must monitor all electronic equipment for malfunctions.", "AUTOMATED ALERT: Ion Storm")


/datum/event/electrical_storm/start()
	for(var/obj/machinery/power/apc/a in world)
		if(!a.z == 3)		continue
		if(prob(35))		new /obj/effect/effect/sparks(a.loc)	//sparks!
		if(prob(3))			a.overload_lighting()					//explodes lights
		if(prob(1))			explosion(a.loc, 1, 2, 3, 4)			//explosions!

		sleep(world.tick_lag)										//makes it look nicer
