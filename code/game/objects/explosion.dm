//TODO: Flash range does nothing currently

///// Z-Level Stuff
proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, z_transfer = 0)
///// Z-Level Stuff
	src = null	//so we don't abort once src is deleted
	spawn(0)


		epicenter = get_turf(epicenter)
		if(!epicenter) return

///// Z-Level Stuff
		if(z_transfer && (devastation_range > 0 || heavy_impact_range > 0))
			//transfer the explosion in both directions
			explosion_z_transfer(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
///// Z-Level Stuff

// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
// Stereo users will also hear the direction of the explosion!
// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
// 3/7/14 will calculate to 80 + 35
		explosionSound( epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range )

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</a>)")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		new /datum/cell_auto_master/explosion( epicenter, devastation_range, heavy_impact_range, light_impact_range )

		//Machines which report explosions.
		for(var/i,i<=doppler_arrays.len,i++)
			var/obj/machinery/doppler_array/Array = doppler_arrays[i]
			if(Array)
				Array.sense_explosion( epicenter.x, epicenter.y, epicenter.z, devastation_range, heavy_impact_range, light_impact_range, 0 )

	return 1

///// Z-Level Stuff
proc/explosion_z_transfer(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, up = 1, down = 1)
	var/turf/controllerlocation = locate(1, 1, epicenter.z)
	for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
		if(controller.down)
			//start the child explosion, no admin log and no additional transfers
			explosion(locate(epicenter.x, epicenter.y, controller.down_target), max(devastation_range - 2, 0), max(heavy_impact_range - 2, 0), max(light_impact_range - 2, 0), max(flash_range - 2, 0), 0, 0)
			if(devastation_range - 2 > 0 || heavy_impact_range - 2 > 0) //only transfer further if the explosion is still big enough
				explosion(locate(epicenter.x, epicenter.y, controller.down_target), max(devastation_range - 2, 0), max(heavy_impact_range - 2, 0), max(light_impact_range - 2, 0), max(flash_range - 2, 0), 0, 1)

		if(controller.up)
			//start the child explosion, no admin log and no additional transfers
			explosion(locate(epicenter.x, epicenter.y, controller.up_target), max(devastation_range - 2, 0), max(heavy_impact_range - 2, 0), max(light_impact_range - 2, 0), max(flash_range - 2, 0), 0, 0)
			if(devastation_range - 2 > 0 || heavy_impact_range - 2 > 0) //only transfer further if the explosion is still big enough
				explosion(locate(epicenter.x, epicenter.y, controller.up_target), max(devastation_range - 2, 0), max(heavy_impact_range - 2, 0), max(light_impact_range - 2, 0), max(flash_range - 2, 0), 1, 0)
///// Z-Level Stuff

/proc/explosionSound( turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range )
	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flash_range)
	var/far_dist = 0
	var/frequency = get_rand_frequency()

	far_dist += heavy_impact_range * 5
	far_dist += devastation_range * 20

	for(var/mob/M in player_list)
		// Double check for client
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && M_turf.z == epicenter.z)
				var/dist = get_dist(M_turf, epicenter)
				// If inside the blast radius + world.view - 2
				if(dist <= round(max_range + world.view - 2, 1))
					M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound

					//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

				else if(dist <= far_dist)
					var/far_volume = Clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
					far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
					M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)

	var/close = range(world.view+round(devastation_range,1), epicenter)
	// to all distanced mobs play a different sound
	for(var/mob/M in world) if(M.z == epicenter.z) if(!(M in close))
		// check if the mob can hear
		if(M.ear_deaf <= 0 || !M.ear_deaf) if(!istype(M.loc,/turf/space))
			M << 'sound/effects/explosionfar.ogg'