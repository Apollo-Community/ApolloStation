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

