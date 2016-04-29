var/global/datum/hanger_controller/hanger_controller

datum/hanger_controller

//Need to expand this
/datum/hanger_controller/proc/get_free_interim_hanger(var/datum/shuttle/S)
	for(var/obj/hanger/square/exterior/space_hanger/blue_space/H in hangers)
		if(H.can_land_at(S))
			return H
	return null

/datum/hanger_controller/proc/ger_free_starting_hanger(var/datum/shuttle/S)
	for(var/obj/hanger/square/exterior/space_hanger/start_hanger/H in hangers)
		if(H.can_land_at(S))
			//error("[H.tag] was chosen for [S.docking_controller_tag]")
			return H
	return null