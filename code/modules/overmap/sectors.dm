// Sector flags
#define SECTOR_KNOWN 1 // Does this sector start out known?
#define SECTOR_STATION 2 // Is this sector part of the station?
#define SECTOR_ALERT 4 // Is this sector affected by alerts such as red alert?
#define SECTOR_LOCAL 8 // Is this sector accessible from the overmap?
#define SECTOR_ADMIN 16 // Is this sector accessible only through admoon intervention?

//===================================================================================
//Hook for building overmap
//===================================================================================
var/global/list/map_sectors = list()

/hook/startup/proc/build_map()
	if(!config.use_overmap)
		return 1
	//testing("Building overmap...")
	var/obj/effect/mapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if( data )
			//testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			map_sectors["[level]"] = new data.obj_type(data)

	generate_sectors_paper() // Making the info for our landmarks paper
	return 1

//===================================================================================
//Metaobject for storing information about sector this zlevel is representing.
//Should be placed only once on every zlevel.
//===================================================================================
/obj/effect/mapinfo/
	name = "map info metaobject"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	invisibility = 101
	var/obj_type		//type of overmap object it spawns
	var/zlevel
	var/mapx			//coordinates on the
	var/mapy			//overmap zlevel
	var/sector_flags = 0

/obj/effect/mapinfo/New()
	tag = "sector[z]"
	zlevel = z
	loc = null

	reportLevels( sector_flags, zlevel )

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector

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

/obj/effect/mapinfo/sector/tcomm_old
	name = "Abandoned Satellite"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/mining_old
	name = "Abandoned Asteroid"
	sector_flags = SECTOR_LOCAL

/obj/effect/mapinfo/sector/centcomm
	name = "Central Command"
	sector_flags = SECTOR_KNOWN | SECTOR_ALERT

/obj/effect/mapinfo/sector/admin_ship
	name = "Valan's Ship"
	sector_flags = SECTOR_ADMIN

/obj/effect/mapinfo/sector/overmap
	name = "Overmap"
	sector_flags = SECTOR_ADMIN

/obj/effect/mapinfo/sector/bluespace
	name = "Bluespace"
	sector_flags = SECTOR_KNOWN


//===================================================================================
//Overmap object representing zlevel
//===================================================================================

/obj/effect/map
	name = ""
	desc = ""
	icon = 'icons/effects/sectors.dmi'

	var/real_name = ""
	var/real_desc = ""
	var/real_icon_state = "unknown"
	var/map_z = 0
	var/obj/effect/mapinfo/metadata = null

/obj/effect/map/New(var/obj/effect/mapinfo/data)
	metadata = data

	if( !metadata )
		del( src )

	map_z = metadata.zlevel
	real_name = metadata.name
	real_desc = metadata.desc

	var/turf/T = null
	for( var/i = 0; i < 50; i++ )
		var/new_x = metadata.mapx ? metadata.mapx : rand(STATION_X-POPULATE_RADIUS, STATION_X+POPULATE_RADIUS)
		var/new_y = metadata.mapy ? metadata.mapx : rand(STATION_Y-POPULATE_RADIUS, STATION_Y+POPULATE_RADIUS)
		T = locate(new_x, new_y, OVERMAP_ZLEVEL)

		if( !sector_exists( T ) || ( metadata.mapx && metadata.mapy ))
			break
		else
			T = null

	if( !T )
		del( src )

	loc = T

	spawn( 5 )
		if( isKnown() )
			reveal()

/obj/effect/map/CanPass(atom/movable/A)
	return 1

/obj/effect/map/Crossed(atom/movable/A)
	if( !isKnown() )
		return

	if( istype( A,/obj/effect/traveler ))
		var/obj/effect/traveler/T = A
		T.enterLocal()

/obj/effect/map/proc/isKnown()
	if(( map_z in config.known_levels ) && ( map_z in config.local_levels ) && !( map_z in config.admin_levels ))
		return 1
	else
		return 0

/obj/effect/map/proc/reveal()
	icon_state = real_icon_state
	name = real_name
	desc = real_desc

	if( !( metadata.sector_flags & SECTOR_KNOWN ))
		metadata.sector_flags |= SECTOR_KNOWN

	reportLevels( metadata.sector_flags, map_z )

/obj/effect/map/sector
	real_name = "generic sector"
	real_desc = "Sector with some stuff in it."
	anchored = 1

//Space stragglers go here

/obj/effect/map/sector/nssapollo
	real_icon_state = "NSS Apollo"
	real_desc = "The NSS Apollo, state-of-the-art phoron research station."

/obj/effect/map/sector/ace
	real_icon_state = "ACE"

/obj/effect/map/sector/engipost
	real_icon_state = "Engi Outpost"

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
