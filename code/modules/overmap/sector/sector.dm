/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in T )
		return 1
	return 0

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector
	var/sector_flags = 0

/obj/effect/mapinfo/sector/station
	name = "NSS Apollo"
	mapx = STATION_X
	mapy = STATION_Y
	obj_type = /obj/effect/map/sector/nssapollo
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL

/obj/effect/mapinfo/sector/station/basement
	name = "NSS Apollo Basement"
	mapx = STATION_X
	mapy = STATION_Y
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_FORBID_RANDOM_TP

/obj/effect/mapinfo/sector/artemis
	name = "NSS Artemis"
	mapx = STATION_X+4
	mapy = STATION_Y
	sector_flags = SECTOR_KNOWN | SECTOR_STATION | SECTOR_ALERT | SECTOR_LOCAL

/obj/effect/mapinfo/sector/ace
	name = "A.C.E."
	obj_type = /obj/effect/map/sector/ace
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL

/obj/effect/mapinfo/sector/engipost
	name = "Engineering Outpost"
	obj_type = /obj/effect/map/sector/engipost
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_LOCAL

/obj/effect/mapinfo/sector/cybersun
	name = "Moon"
	mapx = STATION_X+2
	mapy = STATION_Y
	obj_type = /obj/effect/map/sector/cybersun
	sector_flags = SECTOR_KNOWN | SECTOR_LOCAL | SECTOR_FORBID_RANDOM_TP
	landing_area = /area/planet/moon/landing_zone

/obj/effect/mapinfo/sector/tcomm_old
	name = "Abandoned Satellite"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/mining_old
	name = "Abandoned Asteroid"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/centcomm
	name = "Central Command"
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT | SECTOR_FORBID_RANDOM_TP

/obj/effect/mapinfo/sector/overmap
	name = "Overmap"
	sector_flags = SECTOR_ADMIN | SECTOR_FORBID_RANDOM_TP

/obj/effect/mapinfo/sector/bluespace
	name = "Bluespace"
	sector_flags = SECTOR_KNOWN | SECTOR_FORBID_RANDOM_TP
