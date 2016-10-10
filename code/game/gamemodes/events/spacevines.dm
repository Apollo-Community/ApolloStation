//Carn: Spacevines random event. rjtwins: Edit so that it will pick from vinestart landmarks.

/proc/spacevine_infestation()

	spawn() //to stop the secrets panel hanging
		var/turf/T = pick(vinestart)
		if(!T)
			return
			message_admins("Tried to spawn spacevines but selected turf was null", "EVENT:")
		var/obj/effect/plant_controller/C = new(T) //spawn a controller at turf
		C.seed = seed_types[pick(seed_types)]
		message_admins("Spacevines spawned at [T.loc] ([T.x],[T.y],[T.z])", "EVENT:")