/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in T )
		return 1
	return 0

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector
	var/sector_flags = 0
	var/build_priority = 10 // What order should this object be built? 1 is lowest priority

/obj/effect/mapinfo/sector/getMapLoc()
	var/turf/station = get_turf( locate( "OVERMAP NSS Apollo" ))

	for( var/I = 1, I <= OVERMAP_LOC_ATTEMPTS, I++ )
		var/x_offset = rand( -OVERMAP_POPULATE_RADIUS, OVERMAP_POPULATE_RADIUS )
		var/y_offset = rand( -OVERMAP_POPULATE_RADIUS, OVERMAP_POPULATE_RADIUS )

		var/obj_x = station.x+x_offset
		var/obj_y = station.y+y_offset

		var/turf/T = locate( obj_x, obj_y, OVERMAP_ZLEVEL )
		if( !sector_exists( T ))
			return T

	error( "Could not place [src]!" )

/obj/effect/mapinfo/sector/station
	name = "NSS Apollo"
	obj_type = /obj/effect/map/sector/nssapollo
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/station/getMapLoc()
	return locate( OVERMAP_STATION_X, OVERMAP_STATION_Y, OVERMAP_ZLEVEL )

/obj/effect/mapinfo/sector/artemis
	name = "NSS Artemis"
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/ace
	name = "A.C.E."
	obj_type = /obj/effect/map/sector/ace
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 2

/obj/effect/mapinfo/sector/ace/getMapLoc()
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
	build_priority = 10

/obj/effect/mapinfo/sector/overmap
	name = "Overmap"
	sector_flags = SECTOR_ADMIN | SECTOR_FORBID_RANDOM_TP
	build_priority = 10

/obj/effect/mapinfo/sector/bluespace
	name = "Bluespace"
	sector_flags = SECTOR_KNOWN | SECTOR_FORBID_RANDOM_TP
	build_priority = 10

/obj/effect/mapinfo/sector/asteroid
	name = "asteroid"
	sector_flags = SECTOR_KNOWN | SECTOR_LOCAL
	build_priority = 3

/obj/effect/mapinfo/sector/asteroid/New()
	..()

	name = "asteroid [pick( alphabet_phonetic )]-[rand( 100, 999 )]"
