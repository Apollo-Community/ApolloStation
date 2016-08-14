global var/datum/fusion_controller/fusion_controller = new()

/*
*	Regulates the fusion engine and this components.
*/
/datum/fusion_controller
	var/list/fusion_components
/datum/fusion_controller/New()
	processing_objects.Add(src)
	..()

/datum/fusion_controller/proc/process()
	updatePlasma()

/datum/fusion_controller/proc/generatePlasma()
	for(var/i = 0, i <= 4, i++)
		var/obj/machinery/power/fusion/plasma/plasma = new /obj/machinery/power/fusion/plasma()
		switch(i)
			if(1)
				plasma.loc = get_step(fusion_components[i].loc, EAST)
			if(2)
				plasma.loc = get_step(fusion_components[i].loc, SOUTH)
			if(3)
				plasma.loc = get_step(fusion_components[i].loc, WEST)
			else
				plasma.loc = get_step(fusion_components[i].loc, NORTH)

/datum/fusion_controller/proc/updatePlasma()
	return

/datum/fusion_controller/proc/findComponents()
	var/list/temp_list = list()
	var/obj/machinery/power/fusion/core/core = locate(/obj/machinery/power/fusion/core/core)
	if(isnull(core))
		return 0
	for(dir in list(NORTHWEST,NORTHWEST,SOUTHEAST,SOUTHWEST))
		var/obj/machinery/power/fusion/ring/mag_ring = null
		mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(core, dir))
		if(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring))
			temp_list.Add(mag_ring)
	if(!mag_ring.len == 4)
		return 0
	if(!temp_list[1].dir = SOUTH || !temp_list[1].dir.anchored == 1)
		return 0
	if(!temp_list[2].dir = SOUTH || !temp_list[2].dir.anchored == 1))
		return 0
	if(!temp_list[3].dir = NORTH || !temp_list[3].dir.anchored == 1))
		return 0
	if(!temp_list[4].dir = NORTH || !temp_list[4].dir.anchored == 1))
		return 0

	fusion_components = temp_list
	return 1