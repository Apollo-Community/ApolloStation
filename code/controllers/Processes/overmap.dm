/var/global/datum/controller/process/overmap/overmap

/datum/controller/process/overmap
	var/list/map_sectors = list()

	var/sectors_landmarks_info = ""

	var/list/known_levels = list() // Defines with Z-levels are known
	var/list/station_levels = list()  // Defines which Z-levels the station exists on.
	var/list/alert_levels = list()	// Defines which Z-levels which, for example, a Code Red announcement may affect including such areas as Central Command and the Syndicate Shuttle
	var/list/local_levels = list()	// Defines all Z-levels a character can typically reach
	var/list/admin_levels = list()  // Defines which Z-levels which are for admin functionality, for example
	var/list/can_random_teleport_levels = list() // Levels that you can possibly teleport to

/datum/controller/process/overmap/setup()
	name = "Overmap"
	schedule_interval = 50
	cpu_threshold = 20

	overmap = src

	build_map()
	generate_sectors_paper()

/datum/controller/process/overmap/proc/build_map()
	//testing("Building overmap...")
	var/obj/effect/mapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if( data )
			//testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			reportLevels( data )
			map_sectors["[level]"] = new data.obj_type(data)

/datum/controller/process/overmap/proc/generate_sectors_paper()
	sectors_landmarks_info = "<FONT size = 3><center>Notable Landmarks</center></large></<FONT><hr>"

	for( var/level in map_sectors )
		var/added = 0
		var/known = 0
		var/obj/effect/map/sector = map_sectors["[level]"]

		if( sector.z in overmap.known_levels )
			added = 1
			known = 1

		if( prob( 10 ))
			added = 1

		if( added )
			if( known )
				sectors_landmarks_info += "<br>[sector.name] located in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]<br>"
			else
				sectors_landmarks_info += "<br>Uknown object detected in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]<br>"



/datum/controller/process/overmap/proc/reportLevels( var/obj/effect/mapinfo/sector/S )
	var/flags = S.sector_flags
	var/z = S.zlevel

	if( flags & SECTOR_KNOWN )
		if( !( z in known_levels ))
			known_levels.Add( z )

	if( flags & SECTOR_STATION )
		if( !( z in station_levels ))
			station_levels.Add( z )

	if( flags & SECTOR_ALERT )
		if( !( z in alert_levels ))
			alert_levels.Add( z )

	if( flags & SECTOR_LOCAL )
		if( !( z in local_levels ))
			local_levels.Add( z )

	if( flags & SECTOR_ADMIN )
		if( !( z in admin_levels ))
			admin_levels.Add( z )

	if( !( flags & SECTOR_FORBID_RANDOM_TP ))
		if( !( z in can_random_teleport_levels ))
			can_random_teleport_levels.Add( z )
