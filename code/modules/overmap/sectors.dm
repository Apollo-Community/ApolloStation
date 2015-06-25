
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
		if (data)
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
	var/landing_area 	//type of area used as inbound shuttle landing, null if no shuttle landing area
	var/zlevel
	var/mapx			//coordinates on the
	var/mapy			//overmap zlevel
	var/known = 1

/obj/effect/mapinfo/New()
	tag = "sector[z]"
	zlevel = z
	loc = null

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector

/obj/effect/mapinfo/ship
	name = "generic ship"
	obj_type = /obj/effect/map/ship


/obj/effect/mapinfo/sector/station
	name = "NSS Apollo"
	mapx = STATION_X
	mapy = STATION_Y
	obj_type = /obj/effect/map/sector/nssapollo

/obj/effect/mapinfo/sector/ace
	name = "A.C.E."
	obj_type = /obj/effect/map/sector/ace

/obj/effect/mapinfo/sector/engipost
	name = "Engineering Outpost"
	obj_type = /obj/effect/map/sector/engipost

/obj/effect/mapinfo/sector/tcomm_old
	name = "Abandoned Satellite"

/obj/effect/mapinfo/sector/mining_old
	name = "Abandoned Asteroid"


//===================================================================================
//Overmap object representing zlevel
//===================================================================================

/obj/effect/map
	name = "map object"
	icon = 'icons/effects/sectors.dmi'

	var/map_z = 0
	var/area/shuttle/shuttle_landing
	var/always_known = 1

/obj/effect/map/New(var/obj/effect/mapinfo/data)
	map_z = data.zlevel
	name = data.name
	always_known = data.known

	if(data.icon != 'icons/mob/screen1.dmi')
		icon = data.icon
		icon_state = data.icon_state

	if(data.desc)
		desc = data.desc

	var/turf/T = null
	for( var/i = 0; i < 50; i++ )
		var/new_x = data.mapx ? data.mapx : rand(STATION_X-POPULATE_RADIUS, STATION_X+POPULATE_RADIUS)
		var/new_y = data.mapy ? data.mapy : rand(STATION_Y-POPULATE_RADIUS, STATION_Y+POPULATE_RADIUS)
		T = locate(new_x, new_y, OVERMAP_ZLEVEL)
		if( !sector_exists( T ))
			break
		else
			T = null

	if( !T )
		testing( "Could not find a place for sector, deleting." )
		del( src )

	loc = T
	if(data.landing_area)
		shuttle_landing = locate(data.landing_area)

/proc/sector_exists( var/turf/T )
	for( var/obj/effect/map/sec in T )
		return 1
	return 0

/obj/effect/map/CanPass(atom/movable/A)
	testing("[A] attempts to enter sector\"[name]\"")
	return 1

/obj/effect/map/Crossed(atom/movable/A)
	testing("[A] has entered sector\"[name]\"")
	if (istype(A,/obj/effect/map/ship))
		var/obj/effect/map/ship/S = A
		S.current_sector = src

/obj/effect/map/Uncrossed(atom/movable/A)
	testing("[A] has left sector\"[name]\"")
	if (istype(A,/obj/effect/map/ship))
		var/obj/effect/map/ship/S = A
		S.current_sector = null

/obj/effect/map/sector
	name = "generic sector"
	desc = "Sector with some stuff in it."
	anchored = 1

//Space stragglers go here

/obj/effect/map/sector/nssapollo
	icon_state = "NSS Apollo"

/obj/effect/map/sector/ace
	icon_state = "ACE"

/obj/effect/map/sector/engipost
	icon_state = "Engi Outpost"

/obj/effect/map/sector/temporary
	name = "Deep Space"
	icon_state = ""
	always_known = 0

/obj/effect/map/sector/temporary/New(var/nx, var/ny, var/nz)
	loc = locate(nx, ny, OVERMAP_ZLEVEL)
	map_z = nz
	map_sectors["[map_z]"] = src
	testing("Temporary sector at [x],[y] was created, corresponding zlevel is [map_z].")

/obj/effect/map/sector/temporary/Del()
	map_sectors["[map_z]"] = null
	testing("Temporary sector at [x],[y] was deleted.")
	if (can_die())
		testing("Associated zlevel disappeared.")
		world.maxz--

/obj/effect/map/sector/temporary/proc/can_die(var/mob/observer)
	testing("Checking if sector at [map_z] can die.")
	for(var/mob/M in player_list)
		if(M != observer && M.z == map_z)
			testing("There are people on it.")
			return 0
	for(var/obj/machinery/gate_beacon/B in bluespace_beacons)
		if( B.functional && B.z == map_z)
			testing("There is an active bluespace beacon located there.")
			return 0
	return 1



/*======= LANDMARKS PAPER ==========*/

/obj/item/weapon/paper/sectors
	name = "Notable Landmarks List"

var/global/sectors_landmarks_info = ""
/proc/generate_sectors_paper()
	var/list/required_sectors = list( "NSS Apollo", "A.C.E.", "Engineering Outpost" )
	sectors_landmarks_info = "<FONT size = 3><center>Notable Landmarks</center></large></<FONT><hr>"

	for( var/level in map_sectors )
		var/added = 0
		var/known = 0
		var/obj/effect/map/sector = map_sectors["[level]"]

		if( sector.name in required_sectors )
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
