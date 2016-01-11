//===================================================================================
//Metaobject for storing information about sector this zlevel is representing.
//Should be placed only once on every zlevel.
//===================================================================================
/obj/effect/mapinfo/
	name = "map info metaobject"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	invisibility = 101
	var/obj_type = null		// type of overmap object it spawns
	var/landing_area = null	// if there's a specific area where incoming ships should land
	var/zlevel
	var/mapx			// coordinates on the
	var/mapy			// overmap zlevel

/obj/effect/mapinfo/New()
	tag = "sector[z]"
	zlevel = z
	loc = null

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
		qdel( src )

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
		qdel( src )

	loc = T
