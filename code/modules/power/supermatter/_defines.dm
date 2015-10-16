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

proc/supermatter_delamination( var/turf/epicenter, var/size = 25, var/smlevel = 1, var/transform_mobs = 0, var/adminlog = 1 )
	spawn(0)
		var/start = world.timeofday
		size = min(size, 128)
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		if(adminlog)
			message_admins("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</a>)", "LOG:")
			log_game("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ")

		playsound(epicenter, 'sound/effects/supermatter.ogg', 100, 1, round(size*3,1) )
		new /obj/cell_spawner/v_wave( epicenter, size, smlevel )

		diary << "## Supermatter delamination with size [size]. Took [(world.timeofday-start)/10] seconds."
	return 1


proc/supermatter_convert( var/turf/T, var/transform_mobs = 0, var/level = 1 )
	for( var/mob/item in T.contents )
		if( istype( item, /mob/living ))
			var/mob/living/mob = item

			if( transform_mobs )
				if( ishuman( mob ))
					var/mob/living/carbon/human/M = mob

					if( istype(M.species, /datum/species/human ))
						if( prob( 33 ))
							M.set_species( "Nucleation", 1 )

			mob.apply_effect( level*15, IRRADIATE )
			mob.ex_act( 3 )

	if( istype( T, /turf/simulated/floor ))
		new /datum/cell_auto_master/supermatter_crystal( T, 0, level )

	for( var/obj/machinery/light/item in T.contents )
		item.broken()

proc/blow_lights( var/turf/T )
	for( var/obj/machinery/power/apc/apc in T )
		apc.overload_lighting()
