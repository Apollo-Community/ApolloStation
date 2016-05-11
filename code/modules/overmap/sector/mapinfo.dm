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

/obj/effect/mapinfo/New()
	tag = "sector[z]"
	zlevel = z
	loc = null

/obj/effect/mapinfo/proc/buildMap()
	if( !obj_type )
		return null

	return new obj_type( src, getMapLoc() )

// Defines where the map object spawns
/obj/effect/mapinfo/proc/getMapLoc()
	return locate( 1, 1, OVERMAP_ZLEVEL )
