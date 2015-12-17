/*----------- HIVE TUMOR ------------*/
/obj/machinery/broodswam/large/hive_tumor
	name = "hive tumor"
	desc = "A grotesque lump of flesh, it undulates rhythemically."
	icon_state = "hive_tumor"

	var/datum/cell_auto_master/blotch/controller
	var/list/hive_structures = list()
	var/max_structures = 6

/obj/machinery/broodswam/large/hive_tumor/New()
	controller = new( get_turf( src ))

	ticker.mode.hive = src

	..()

/obj/machinery/broodswam/large/hive_tumor/Destroy()
	ticker.mode.hive = null

	..()

/obj/machinery/broodswam/large/hive_tumor/ex_act()
	return

/obj/machinery/broodswam/large/hive_tumor/attack_hand( mob/user )
	if( isbroodswarm( user ))
		ui_interact( user )
		return

	user.do_attack_animation( src )

	return

/obj/machinery/broodswam/large/hive_tumor/blob_act()
	return

/obj/machinery/broodswam/large/hive_tumor/attack_tk()
	return

/obj/machinery/broodswam/large/hive_tumor/attack_generic()
	return

/obj/machinery/broodswam/large/hive_tumor/attackby()
	return

/obj/machinery/broodswam/large/hive_tumor/proc/addStructure( var/obj/machinery/M )
	if( !M || !istype( M ))
		return 0

	if( hive_structures.len >= max_structures )
		return 0

	if( M in hive_structures )
		return 0

	hive_structures += M

	return hive_structures.len

/obj/machinery/broodswam/large/hive_tumor/proc/removeStructure( var/obj/machinery/M )
	hive_structures -= M

	return 1
