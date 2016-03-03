// Makes minor explosions to make the station a little bruised
proc/station_erosion( var/erosion_level = 60 )
	for( var/i = 0; i < erosion_level;  )
		var/turf/T = locate( rand(0, 255), rand(0, 255), pick( config.station_levels ))

		if( !istype( T, /turf/space ))
			var/size = rand( 5, 10 )
			if( !near_space( T, size+1 )) // We want to lower the station structural integrity, yet keep it habitable
				explosion_rec(T, size, 3)
				i++

	for( var/area/A in all_areas )
		for( var/obj/machinery/power/apc/P in A )
			if( prob( 75 ))
				P.overload_lighting()
		for( var/obj/machinery/door/airlock/D in A )
			if( prob( 10 ))
				var/max = D.maxhealth
				D.take_damage( rand( max/4, max+( max/4 )))

	return

// Just adds random items strewn around the map
proc/populate_random_items( var/max_guns = 20 )
	for( var/gun_count = 0; gun_count < max_guns;  )
		var/turf/T = locate( rand(0, 255), rand(0, 255), pick( config.station_levels ))
		if( !T )
			continue

		if( istype( T, /turf/space ))
			continue

		if( !isfloor( T ) )
			continue

		new /obj/random/gun(T)
		gun_count++

		return

// Spreads all of the guns found on the map around the map
proc/spread_guns()
	var/list/guns = list()

	for( var/area/A in all_areas )
		for( var/obj/item/weapon/gun/G in A )
			guns.Add( G )

	for( var/obj/item/weapon/gun/G in guns )
		var/area/A = pick( all_areas )
		var/turf/simulated/floor/T = pick( A.contents )
		G.loc = T

	return

// Makes areas around the map barricaded
proc/populate_barricades( var/barricade_chance = 10 )
	for( var/area/A in all_areas )
		if( prob( barricade_chance ))
			barricade_area( A )

	return

// Barricades the given area
proc/barricade_area( var/area/area )
	for( var/turf/T in area )
		var/spawn_barricade = 0
		for( var/obj/O in T )
			if( !istype( O, /obj/structure/barricade/wooden ))
				if( istype( O, /obj/structure/window/reinforced )) // Barricading windows
					if( prob( 90 ))
						spawn_barricade = 1
				if( istype( O, /obj/machinery/door/airlock )) // Barricading doors
					if( prob( 10 ))
						spawn_barricade = 1
			else
				spawn_barricade = 0
				break
		if( spawn_barricade )
			new /obj/structure/barricade/wooden(T)
	return

proc/near_space( var/turf/epicenter, var/range )
	for( var/turf/T in orange( range, epicenter ))
		if( istype( T, /turf/space ))
			return 1
	return 0