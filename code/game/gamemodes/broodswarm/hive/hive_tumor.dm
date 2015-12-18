w/*----------- HIVE TUMOR ------------*/
/obj/machinery/broodswam/large/hive_tumor
	name = "hive tumor"
	desc = "A grotesque lump of flesh, it undulates rhythemically."
	icon_state = "hive_tumor"

	var/ui_title = "Hive Nerve"
	var/datum/cell_auto_master/blotch/controller
	var/list/hive_structures = list()
	var/max_structures = 6

/obj/machinery/broodswam/large/hive_tumor/New()
	controller = new( get_turf( src ))

	ticker.mode.hive = src

	..()

	if( !ticker.addToHive( src ))
		qdel( src )

/obj/machinery/broodswam/large/hive_tumor/Destroy()
	ticker.mode.hive = null

	..()

/obj/machinery/broodswam/large/hive_tumor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	// this is the data which will be sent to the ui
	var/data[0]
	data["structure_count"] = hive_structures.len
	data["max_structures"] = max_structures

		// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "hive_tumor.tmpl", ui_title, 600, 385)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/broodswam/large/hive_tumor/Topic(href, href_list)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

/*
	if(href_list["state"])
		state = href_list["state"]
	else if(href_list["run_scan"])
		src.check_parts()
*/

	nanomanager.update_uis(src)
	add_fingerprint(usr)

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

	world << "Addded [M]"
	hive_structures.Add( M )

	return hive_structures.len

/obj/machinery/broodswam/large/hive_tumor/proc/removeStructure( var/obj/machinery/M )
	hive_structures.Remove( M )

	return 1
