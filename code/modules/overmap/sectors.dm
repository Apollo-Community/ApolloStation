/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector
	var/sector_flags = 0

/obj/effect/mapinfo/sector/New()
	..()

	reportLevels( sector_flags, zlevel )

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
	sector_flags = SECTOR_KNOWN | SECTOR_STATION

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
	sector_flags = SECTOR_KNOWN | SECTOR_LOCAL
	landing_area = /area/planet/moon/landing_zone

/obj/effect/mapinfo/sector/tcomm_old
	name = "Abandoned Satellite"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/mining_old
	name = "Abandoned Asteroid"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/centcomm
	name = "Central Command"
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT

/obj/effect/mapinfo/sector/overmap
	name = "Overmap"
	sector_flags = SECTOR_ADMIN

/obj/effect/mapinfo/sector/bluespace
	name = "Bluespace"
	sector_flags = SECTOR_KNOWN


/obj/effect/map/sector
	real_name = "generic sector"
	real_desc = "Sector with some stuff in it."
	anchored = 1

/obj/effect/map/sector/New()
	..()

	spawn( 5 )
		if( isKnown() )
			reveal()

/obj/effect/map/sector/CanPass(atom/movable/A)
	return 1

/obj/effect/map/sector/Crossed(atom/movable/A)
	if( !isKnown() )
		return

	if( istype( A,/obj/effect/traveler ))
		var/obj/effect/traveler/T = A
		T.enterLocal()

/obj/effect/map/sector/proc/isKnown()
	if(( map_z in config.known_levels ) && ( map_z in config.local_levels ) && !( map_z in config.admin_levels ))
		return 1
	else
		return 0

/obj/effect/map/sector/proc/reveal()
	icon_state = real_icon_state
	name = real_name
	desc = real_desc

	var/obj/effect/mapinfo/sector/data = metadata

	if( !data )
		return

	if( !( data.sector_flags & SECTOR_KNOWN ))
		data.sector_flags |= SECTOR_KNOWN

	reportLevels( data.sector_flags, map_z )

//Space stragglers go here

/obj/effect/map/sector/nssapollo
	real_icon_state = "NSS Apollo"
	real_desc = "The NSS Apollo, state-of-the-art phoron research station."

/obj/effect/map/sector/ace
	real_icon_state = "ACE"

/obj/effect/map/sector/engipost
	real_icon_state = "Engi Outpost"

/obj/effect/map/sector/cybersun
	real_icon_state = "Moon"

/proc/reportLevels( var/flags, var/z )
	if( flags & SECTOR_KNOWN )
		if( !( z in config.known_levels ))
			config.known_levels.Add( z )

	if( flags & SECTOR_STATION )
		if( !( z in config.station_levels ))
			config.station_levels.Add( z )

	if( flags & SECTOR_ALERT )
		if( !( z in config.alert_levels ))
			config.alert_levels.Add( z )

	if( flags & SECTOR_LOCAL )
		if( !( z in config.local_levels ))
			config.local_levels.Add( z )

	if( flags & SECTOR_ADMIN )
		if( !( z in config.admin_levels ))
			config.admin_levels.Add( z )

/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in T )
		return 1
	return 0

/*======= LANDMARKS PAPER ==========*/

/obj/item/weapon/paper/sectors
	name = "Notable Landmarks List"

var/global/sectors_landmarks_info = ""
/proc/generate_sectors_paper()
	sectors_landmarks_info = "<FONT size = 3><center>Notable Landmarks</center></large></<FONT><hr>"

	for( var/level in map_sectors )
		var/added = 0
		var/known = 0
		var/obj/effect/map/sector = map_sectors["[level]"]

		if( sector.z in config.known_levels )
			added = 1
			known = 1

		if( prob( 10 ))
			added = 1

		if( added )
			if( known )
				sectors_landmarks_info += "<br>[sector.name] located in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]<br>"
			else
				sectors_landmarks_info += "<br>Uknown object detected in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]<br>"


/obj/item/weapon/paper/sectors/New()
	..()

	spawn( 20 )
		info = sectors_landmarks_info
		update_icon()
