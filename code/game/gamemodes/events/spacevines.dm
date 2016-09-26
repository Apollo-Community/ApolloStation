//Carn: Spacevines random event.
/proc/spacevine_infestation()

	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(F.contents.len < 2)
					turfs += F
		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			new/obj/effect/plant_controller(T) //spawn a controller at turf
			message_admins("Spacevines spawned at [T.loc] ([T.x],[T.y],[T.z])", "EVENT:")
