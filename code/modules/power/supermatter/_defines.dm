var/list/SM_COLORS = list( SM_DEFAULT_COLOR, \
						   "#00FF99", \
						   "#0099FF", \
						   "#6600FF", \
						   "#FF00FF", \
						   "#FF3399", \
						   "#FFFF00", \
						   "#FF6600", \
						   "#FF0000" )

/proc/getSMColor( var/level )
	if( level < 1 )
		level = 1

	if( level > 9 )
		level = 9

	return SM_COLORS[level]

proc/supermatter_delamination(var/turf/epicenter, var/size, var/transform_mobs = 0, var/smlevel = 1, var/adminlog = 1, var/rads = 0)
	spawn(0)
		var/start = world.timeofday
		size = min(size, 128)
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		if(adminlog)
			message_admins("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</a>)", "LOG:")
			log_game("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ")

		playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(size*2,1) )
		playsound(epicenter, "explosion", 100, 1, round(size,1) )
		explosion(epicenter, 0, 0, 0, max(size/5, 3), 0)
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		var/x = epicenter.x
		var/y = epicenter.y
		var/z = epicenter.z

		//epicenter.ChangeTurf( /turf/simulated/floor/plating/smatter )

		for(var/mob/living/mob in orange( epicenter, size*2 )) // Irradiate area twice the size of the main blast
			if(epicenter.z == mob.loc.z)
				if( ishuman(mob) )
					//Hilariously enough, running into a closet should make you get hit the hardest.
					var/mob/living/carbon/human/H = mob
					H.hallucination += max(50, min(size*10, smvsc.psionic_power*10 * sqrt(1 / (get_dist(mob, epicenter) + 1)) ) )
				if( !rads )
					rads = size*10 * sqrt( 1 / (get_dist(mob, epicenter) + 1) ) * smlevel
				mob.apply_effect(rads, IRRADIATE)

		for(var/i=0, i<size, i++) // An awful way to do this, but i'm tired
			for(var/j=0, j<i, j++)
				var/turf/cur_turf = locate((x-i)+j, y+j, z )
				var/dist = get_dist( cur_turf, epicenter )
				var/percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs, smlevel )

				cur_turf = locate(x+j, (y+i)-j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs, smlevel )

				cur_turf = locate((x+i)-j, y-j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs, smlevel )

				cur_turf = locate(x-j, (y-i)+j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs, smlevel )

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0

		diary << "## Supermatter delamination with size [size]. Took [(world.timeofday-start)/10] seconds."
	return 1


proc/supermatter_convert( var/turf/T, var/transform_mobs = 0, var/level = 1 )
	if( transform_mobs )
		for( var/mob/item in T.contents )
			if( ishuman( item ))
				var/mob/living/carbon/human/M = item
				if( istype(M.species, /datum/species/human ))
					if( prob( 33 ))
						M.set_species( "Nucleation", 1 )
			item.ex_act( 3 )

	if( istype( T, /turf/simulated/floor ))
		new /obj/effect/supermatter_crystal(T, max(1, rand(level-1, level)))

proc/blow_lights( var/turf/T )
	for( var/obj/machinery/power/apc/apc in T )
		apc.overload_lighting()
