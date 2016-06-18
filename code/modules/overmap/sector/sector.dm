/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in range( 1, T ))
		return 1
	return 0

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector
	var/sector_flags = 0
	var/build_priority = 10 // What order should this object be built? 1 is lowest priority

/obj/effect/mapinfo/sector/getMapLoc()
	var/turf/station = get_turf( locate( "OVERMAP NOS Apollo" ))

	if( !station )
		return locate( OVERMAP_STATION_X, OVERMAP_STATION_Y, OVERMAP_ZLEVEL )

	for( var/I = 1, I <= OVERMAP_LOC_ATTEMPTS, I++ )
		var/x_offset = rand( -OVERMAP_POPULATE_RADIUS, OVERMAP_POPULATE_RADIUS )
		var/y_offset = rand( -OVERMAP_POPULATE_RADIUS, OVERMAP_POPULATE_RADIUS )

		var/obj_x = station.x+x_offset
		var/obj_y = station.y+y_offset

		var/turf/T = locate( obj_x, obj_y, OVERMAP_ZLEVEL )
		if( !sector_exists( T ))
			return T

	log_debug( "Could not place [src]!" )

/obj/effect/mapinfo/sector/station
	name = "NOS Apollo"
	obj_type = /obj/effect/map/sector/apollo
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/station/getMapLoc()
	return locate( OVERMAP_STATION_X, OVERMAP_STATION_Y, OVERMAP_ZLEVEL )

/obj/effect/mapinfo/sector/artemis
	name = "NSS Artemis"
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/slater
	name = "NMV Slater"
	obj_type = /obj/effect/map/sector/slater
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 2
	edge_length = 55

/obj/effect/mapinfo/sector/slater/getMapLoc()
	return locate( OVERMAP_STATION_X+4, OVERMAP_STATION_Y-4, OVERMAP_ZLEVEL )

/obj/effect/mapinfo/sector/engipost
	name = "Engineering Outpost"
	obj_type = /obj/effect/map/sector/engipost
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 2

/obj/effect/mapinfo/sector/engipost/getMapLoc()
	return locate( OVERMAP_STATION_X-2, OVERMAP_STATION_Y, OVERMAP_ZLEVEL )

/obj/effect/mapinfo/sector/moon
	name = "Moon"
	obj_type = /obj/effect/map/sector/moon
	sector_flags = SECTOR_KNOWN | SECTOR_LOCAL | SECTOR_FORBID_RANDOM_TP
	landing_area = /area/planet/moon/landing_zone
	build_priority = 2

/obj/effect/mapinfo/sector/moon/getMapLoc()
	return locate( OVERMAP_STATION_X+2, OVERMAP_STATION_Y+2, OVERMAP_ZLEVEL )

/obj/effect/mapinfo/sector/tcomm_old
	name = "Abandoned Satellite"
	sector_flags = SECTOR_LOCAL
	build_priority = 10

/obj/effect/mapinfo/sector/mining_old
	name = "Abandoned Asteroid"
	sector_flags = SECTOR_LOCAL
	build_priority = 10

/obj/effect/mapinfo/sector/centcomm
	name = "Central Command"
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_FORBID_RANDOM_TP
	obj_type = null
	build_priority = 10

/obj/effect/mapinfo/sector/overmap
	name = "Overmap"
	sector_flags = SECTOR_ADMIN | SECTOR_FORBID_RANDOM_TP
	obj_type = null
	build_priority = 10

/obj/effect/mapinfo/sector/bluespace
	name = "Bluespace"
	sector_flags = SECTOR_KNOWN | SECTOR_FORBID_RANDOM_TP
	obj_type = null
	build_priority = 10

/obj/effect/mapinfo/sector/asteroid
	name = "asteroid"
	obj_type = /obj/effect/map/sector/asteroid
	sector_flags = SECTOR_LOCAL
	build_priority = 3

/obj/effect/mapinfo/sector/asteroid/getMapLoc()
	var/turf/center = get_turf( locate( "OVERMAP NMV Slater" ))

	if( !center )
		return ..()

	for( var/I = 1, I <= OVERMAP_LOC_ATTEMPTS, I++ )
		var/x_offset = rand( -OVERMAP_POPULATE_RADIUS/2, OVERMAP_POPULATE_RADIUS/2 )
		var/y_offset = rand( -OVERMAP_POPULATE_RADIUS/2, OVERMAP_POPULATE_RADIUS/2 )

		var/obj_x = center.x+x_offset
		var/obj_y = center.y+y_offset

		var/turf/T = locate( obj_x, obj_y, OVERMAP_ZLEVEL )
		if( !sector_exists( T ))
			return T


/obj/effect/mapinfo/sector/asteroid/initliazeMap()
	..()

	name = "asteroid [pick( alphabet_uppercase )]-[rand( 100, 999 )]"

	var/fill_rate = 52 // % of the area that will be filled at the start
	var/smoothness = 2 // How smooth the asteroid will be

	var/array_maxx = world.maxx-(TRANSITION_EDGE_LENGTH*4)
	var/array_maxy = world.maxy-(TRANSITION_EDGE_LENGTH*4)

	// The array for the asteroid data
	var/list/list/asteroid[array_maxx][array_maxy]

	// Populates the asteroid array with random data
	for( var/y_pos = 1, y_pos <= array_maxx, y_pos++ )
		for( var/x_pos = 1, x_pos <= array_maxx, x_pos++ )
			if(( x_pos <= 1 ) || ( x_pos >= array_maxx ) || ( y_pos <= 1 ) || ( y_pos >= array_maxy ))
				asteroid[x_pos][y_pos] = 0 // If we're on an edge, we are empty space
			else
				asteroid[x_pos][y_pos] = prob( fill_rate )

	// Generates the asteroid
	for( var/I = 1, I <= smoothness, I++ )
		var/list/list/buffer_asteroid = asteroid // We use a buffer so that we're not writing over the data we're reading
		for( var/y_pos = 1, y_pos <= array_maxy, y_pos++ )
			for( var/x_pos = 1, x_pos <= array_maxx, x_pos++ )
				buffer_asteroid[x_pos][y_pos] = checkNeighbors( asteroid, x_pos, y_pos, array_maxx, array_maxy )

		asteroid = buffer_asteroid // Writes this iteration onto the original data

	var/start_x = TRANSITION_EDGE_LENGTH*2
	var/start_y = TRANSITION_EDGE_LENGTH*2

	var/area/mine/unexplored/A = new
	A.name = name

	// Placing the asteroid
	for( var/y_pos = 1, y_pos <= array_maxy, y_pos++ )
		for( var/x_pos = 1, x_pos <= array_maxx, x_pos++ )
			if( asteroid[x_pos][y_pos] == 1 )
				var/turf/T = locate( start_x+x_pos, start_y+y_pos, zlevel )
				if( !T )
					continue

				T.ChangeTurf( /turf/simulated/mineral/random )
				A.contents += T

	spawn( 10 )
		master_controller.asteroid_ore_map.apply_to_asteroid( zlevel )

	return 1

// This is used only by the generation algorithm, it checks neighbors with a 4-5 rule
// Return 1 if the given position should become solid
/obj/effect/mapinfo/sector/asteroid/proc/checkNeighbors( var/list/list/data, var/x_pos, var/y_pos, var/maxx, var/maxy )
	if(( x_pos <= 1 ) || ( x_pos >= maxx ) || ( y_pos <= 1 ) || ( y_pos >= maxy ))
		return 0

	var/is_solid = data[x_pos][y_pos]
	var/solid_count = 0
	if( is_solid )
		solid_count = -1 // We dont count ourselves when counting neighbors

	for( var/y_neighbor = -1, y_neighbor <= 1, y_neighbor++ )
		for( var/x_neighbor = -1, x_neighbor <= 1, x_neighbor++ )
			if( data[x_pos+x_neighbor][y_pos+y_neighbor] == 1 )
				solid_count++

	if( is_solid && solid_count >= 4 )
		return 1
	else if( solid_count >= 5 )
		return 1
	else
		return 0
