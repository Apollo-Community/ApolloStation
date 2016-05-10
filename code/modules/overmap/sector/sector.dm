/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in T )
		return 1
	return 0

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector
	var/sector_flags = 0
	var/build_priority = 10 // What order should this object be built? 1 is lowest priority

/obj/effect/mapinfo/sector/station
	name = "NSS Apollo"
	mapx = STATION_X
	mapy = STATION_Y
	obj_type = /obj/effect/map/sector/nssapollo
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/artemis
	name = "NSS Artemis"
	mapx = STATION_X+4
	mapy = STATION_Y
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 1

/obj/effect/mapinfo/sector/ace
	name = "A.C.E."
	obj_type = /obj/effect/map/sector/ace
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 2

/obj/effect/mapinfo/sector/engipost
	name = "Engineering Outpost"
	obj_type = /obj/effect/map/sector/engipost
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL
	build_priority = 2

/obj/effect/mapinfo/sector/moon
	name = "Moon"
	mapx = STATION_X+2
	mapy = STATION_Y
	obj_type = /obj/effect/map/sector/moon
	sector_flags = SECTOR_KNOWN | SECTOR_LOCAL | SECTOR_FORBID_RANDOM_TP
	landing_area = /area/planet/moon/landing_zone
	build_priority = 2

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
