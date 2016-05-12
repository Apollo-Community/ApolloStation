#define MIN_ASTEROIDS 3
#define MAX_ASTEROIDS 6

/var/global/datum/controller/process/overmap/overmap

/datum/controller/process/overmap
	var/list/map = list() // Markers on the overmap
	var/list/mapinfo = list() // Metadata objects

	var/sectors_landmarks_info = ""

	var/list/known_levels = list() // Defines with Z-levels are known
	var/list/station_levels = list()  // Defines which Z-levels the station exists on.
	var/list/alert_levels = list()	// Defines which Z-levels which, for example, a Code Red announcement may affect including such areas as Central Command and the Syndicate Shuttle
	var/list/local_levels = list()	// Defines all Z-levels a character can typically reach
	var/list/admin_levels = list()  // Defines which Z-levels which are for admin functionality, for example
	var/list/can_random_teleport_levels = list() // Levels that you can possibly teleport to

	var/list/teleportlocs = list()
	var/list/ghostteleportlocs = list()

/datum/controller/process/overmap/New()
	..()

	overmap = src

/datum/controller/process/overmap/setup()
	name = "Overmap"
	schedule_interval = 50
	cpu_threshold = 20

	// Collecting mapinfo objects
	mapinfo += collect_map()
	mapinfo += collect_asteroid_field()

	testing( "Overmap has [mapinfo.len] objects" )
	// Placing the map objects
	build_map( mapinfo )

	testing("Overmap built!")

	// Generating the landmarks paper
	generate_sectors_paper()

/datum/controller/process/overmap/proc/collect_map()
	testing("Collecting overmap objects...")
	. = list()

	var/obj/effect/mapinfo/sector/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if( data )
			.[data] = data.build_priority

	return .

// Creates a field of asteroids near the mining shuttle
/datum/controller/process/overmap/proc/collect_asteroid_field()
	testing("Collecting overmap asteroids...")
	. = list()

	var/asteroid_z_start = world.maxz+1 // The z level at the asteroid field starts at
	var/asteroid_number = rand( MIN_ASTEROIDS, MAX_ASTEROIDS ) // The number of random asteroids to add

	// If we dont want to add an asteroid belt
	if( !asteroid_number )
		return 0

	world.maxz = world.maxz+asteroid_number

	for(var/level in asteroid_z_start to world.maxz)
		var/origin = locate( 1, 1, level )
		var/obj/effect/mapinfo/sector/data = new /obj/effect/mapinfo/sector/asteroid( origin )
		.[data] = data.build_priority

	return .

/datum/controller/process/overmap/proc/build_map( var/list/data )
	testing("Building overmap...")

	if( !data )
		error( "Failed to create overmap, no data!" )
		return 0

	var/list/list/sorted_lists = list() // a list of lists
	var/max_priority = 0

	// Finding the max priority level
	for( var/obj/effect/mapinfo/sector/S in data )
		if( max_priority < S.build_priority )
			max_priority = S.build_priority
			sorted_lists.len = max_priority

	// Adding individual lists
	for( var/level in 1 to max_priority )
		sorted_lists[level] = list( list() )

	// Sorting the data into each individual priority level
	for( var/obj/effect/mapinfo/sector/S in data )
		if( istype( S ))
			sorted_lists[S.build_priority] += S

	// Building the map
	for( var/level in 1 to max_priority )
		if( !sorted_lists[level] )
			continue
		var/list/L = sorted_lists[level]
		for( var/obj/effect/mapinfo/sector/S in L )
			reportSector( S )

	return 1

/datum/controller/process/overmap/proc/generate_sectors_paper()
	sectors_landmarks_info = "<FONT size = 3><center>Notable Landmarks</center></large></<FONT><hr>"

	for( var/level in map )
		var/added = 0
		var/known = 0
		var/obj/effect/map/sector = map["[level]"]

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

/datum/controller/process/overmap/proc/reportSector( var/obj/effect/mapinfo/sector/data )
	if( !data )
		return 0

	reportLevels( data )
	map["[data.zlevel]"] = data.buildMap()
	testing("Located sector \"[data.name]\" corresponding to zlevel [data.zlevel]")

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

/datum/controller/process/overmap/proc/setupTeleportLocs()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station)) continue
		if(teleportlocs.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z in station_levels)
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR

	teleportlocs = sortAssoc(teleportlocs)

	return 1

/datum/controller/process/overmap/proc/setupGhostTeleportLocs()
	for(var/area/AR in world)
		if(ghostteleportlocs.Find(AR.name)) continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/derelict) || istype(AR, /area/tdome) || istype(AR, /area/shuttle/specops/centcom))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z in local_levels)
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR

	ghostteleportlocs = sortAssoc(ghostteleportlocs)

	return 1
