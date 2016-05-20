var/global/datum/hanger_controller/hanger_controller
var/global/datum/hanger_scheduler/hanger_scheduler

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
			return H
	return null

/datum/hanger_controller/proc/get_free_space_hangers(var/datum/shuttle/S)
	var/list/free_hangers = list()
	for(var/obj/hanger/square/exterior/space_hanger/H in hangers)
		if(istype(H, /obj/hanger/square/exterior/space_hanger/start_hanger) || istype(H, /obj/hanger/square/exterior/space_hanger/blue_space/))
			continue
		if(H.can_land_at(S))
			free_hangers += H
	return free_hangers

//Return a random free hanger.
/datum/hanger_controller/proc/get_free_space_hanger(var/datum/shuttle/S)
	var/list/free_hangers = get_free_space_hangers(S)
	if(isnull(free_hangers))
		return null
	//error("Getting a free space hanger for [S.docking_controller_tag] there are [free_hangers.len] hangers available")
	var/i = round(rand(1,free_hangers.len))
	return free_hangers[i]


//Hanger scheduler manages shuttle that are positioned in intermediate hangers.
//Shuttles need to request scheduling.
datum/hanger_scheduler

//List of all shuttles currently beeing scheduled
var/list/shuttle_to_schedule = list()

//Check for each shuttle in the list if they can jump to their final destination
//Only think about moving if the shuttle is done moving to its parking position
datum/hanger_scheduler/proc/process()
	////error("hanger_schedular heartbeat")
	for(var/datum/scheduled_shuttle/S in shuttle_to_schedule)
		if(!S.shuttle.moving_status == SHUTTLE_SCHEDULING)
			continue
		if(!S.dest_hanger.can_land_at(S.shuttle))
			continue

		remove_shuttle(S)
		S.shuttle.move(S.dest_hanger, null, 0)
		inform_shuttle(S.shuttle, 0)

//Add the shuttle to the to schedule shuttles and park it at an empty spot near the station.
//TODO: Build more logic into this it now just picks an emtpy space hanger at random.
datum/hanger_scheduler/proc/add_shuttle(datum/shuttle/S, var/obj/hanger/H)
	//error("Hanger_scheduler adding : [S.docking_controller_tag]")
	var/datum/scheduled_shuttle/scheduled_shuttle = new()
	scheduled_shuttle.shuttle = S
	scheduled_shuttle.dest_hanger = H
	scheduled_shuttle.curr_hanger = S.current_hanger
	shuttle_to_schedule += scheduled_shuttle
	inform_shuttle(S, 1)

datum/hanger_scheduler/proc/remove_shuttle(datum/scheduled_shuttle/s)
	shuttle_to_schedule -= s
	s.shuttle.in_transit = 0
	s.shuttle.moving_status = SHUTTLE_IDLE

//Inform the occupants of the shuttle they are beeing moved to a holding location or their destination.
datum/hanger_scheduler/proc/inform_shuttle(datum/shuttle/s, var/type)
	var/message = null
	switch (type)
		if(0)	message = "The shuttle computer prompts: The shuttle destination has been cleared proceeding to dock."
		if(1)	message = "The shuttle computer prompts: The shuttle as been parked at a temporary location near the the station until its destination is cleared."
		if(2)	message = "The shuttle computer prompts: Starting redirection to space to make room for priority shuttle"
		else	return

	for(var/turf/T in s.shuttle_turfs)
		for(var/mob/M in T)
			M << message

datum/hanger_scheduler/proc/divert(var/datum/shuttle/s)
	var/obj/hanger/H = hanger_controller.get_free_space_hangers(s)
	s.move(H,null,0)
	inform_shuttle(s, 2)


//Wrapper datum
datum/scheduled_shuttle
	var/datum/shuttle/shuttle
	var/obj/hanger/dest_hanger
	var/obj/hanger/curr_hanger