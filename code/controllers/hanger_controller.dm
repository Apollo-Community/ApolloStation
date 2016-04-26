var/global/datum/hanger_controller/hanger_controller

datum/hanger_controller
	var/list/hangers
	var/list/hangers_as
	var/list/blue_space_hangers
	var/list/blue_space_hangers_as
	var/list/start_hangers_as
	var/list/start_hangers

datum/hanger_controller/New()
	hangers = new /list()
	hangers_as = new /list()
	blue_space_hangers = new /list()
	blue_space_hangers_as = new /list()
	start_hangers_as = new /list()
	start_hangers = new /list()

	//Generating bluespace hangers for long jumps
	/*
	for(var/i=1, i <= 7, i++)
		H = new /datum/hanger()
		H.tag = "Blue_Space_[i]"
		H.exterior = 1
		H.hanger_area = locate(text2path("/area/space/bluespace/hanger_[i]"))
		blue_space_hangers_as[H.tag] = H
		blue_space_hangers += H

	//Generating CC starting hangers for generic ships
	for(var/i=1, i <= 10, i++)
		H = new /datum/hanger()
		H.tag = "Start_Hanger_[i]"
		H.exterior = 1
		H.hanger_area = locate(text2path("/area/space/s_hanger_[i]"))
		start_hangers_as[H.tag] = H
		start_hangers += H
	*/

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