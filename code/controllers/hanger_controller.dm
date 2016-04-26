var/global/datum/hanger_controller/hanger_controller

datum/hanger_controller

datum/hanger_controller/New()

//Need to expand this
/datum/hanger_controller/proc/get_free_interim_hanger(var/datum/shuttle/S)
	for(var/obj/hanger/H in blue_space_hangers)
		if(H.can_land_at(S))
			return H
	return null

/datum/hanger_controller/proc/ger_free_starting_hanger(var/datum/shuttle/S)
	for(var/obj/hanger/H in start_hangers)
		if(H.can_land_at(S))
			return H
	return null