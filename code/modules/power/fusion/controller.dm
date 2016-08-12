global var/datum/fusion_controller/fusion_controller = new()

/datum/fusion_controller
	var/list/fusion_components
/datum/fusion_controller/New()
	processing_objects.Add(src)
	..()

/datum/fusion_controller/proc/process()


/datum/fusion_controller/proc/generatePlasma()


/datum/fusion_controller/proc/updatePlasma()


/datum/fusion_controller/proc/findComponents()
	var/obj/machinery/power/fusion/ring/mag_ring = null
	var/list/temp_list = list()
	for(dir in list(NORTHWEST,NORTHWEST,SOUTHEAST,SOUTHWEST))
		mag_ring = locate(/obj/machinery/gravity_generator/, get_step(src, dir))
		if(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring))
			temp_list.Add(mag_ring)
	if(mag_ring.len == 4)
		fusion_components = temp_list
		return 1
	return 0