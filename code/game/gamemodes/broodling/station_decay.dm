// Makes minor explosions to make the station a little bruised
proc/station_erosion( var/erosion_level )
	var/i = 0
	while( i<erosion_level )
		var/turf/T = locate( rand(0, 255), rand(0, 255), 1 )

		if( !istype( T, /turf/space ))
			var/size = rand( 2, 10 )
			if( !near_space( T, size+1 )) // We want to lower the station structural integrity, yet keep it habitable
				explosion(T, 0, 0, size, 0, 0)
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
proc/populate_random_items()
	var/gun_count = 0

	for( var/area/A in all_areas )
		for( var/turf/T in A )
			if( prob( 0.001 )) // 1/10000 chance for a gun to spawn on the ground
				new /obj/random/gun(T)
				gun_count++
	world << "Created [gun_count] guns around the map. Go find 'em!"
	return

// Spreads all of the guns found on the map around the map
proc/spread_guns()
	var/list/guns = list()

	for( var/area/A in all_areas )
		for( var/obj/item/weapon/gun/G in A )
			guns.Add( G )
			world << "Added [G] to guns."

	for( var/obj/item/weapon/gun/G in guns )
		var/area/A = pick( all_areas )
		var/turf/simulated/floor/T = pick( A.contents )
		world << "Moved [G] from [G.loc] to [T]."
		G.loc = T

	return

// Makes areas around the map barricaded
proc/populate_barricades( var/barricade_chance )
	var/areas_barricaded = 0

	for( var/area/A in all_areas )
		if( prob( barricade_chance ))
			barricade_area( A )
			areas_barricaded++

	world << "Barricaded [areas_barricaded] areas! Good luck getting inside!"
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