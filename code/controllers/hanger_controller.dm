var/global/datum/hanger_controller/hanger_controller
var/global/datum/hanger_schedular/hanger_schedular

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
	var/list/hangers = list()
	for(var/obj/hanger/square/exterior/space_hanger/H in hangers)
		if(!istype(O, var/obj/hanger/square/exterior/space_hanger/start_hanger) && !istype(O, var/obj/hanger/square/exterior/space_hanger/blue_space)
			if(H.can_land_at(S))
				return hangers += H
	return null

//Return a random free hanger.
/datum/hanger_controller/proc/get_free_space_hanger(var/datum/shuttle/S)
	var/list/hangers = get_free_space_hangers(S)
	if(isnull(hangers))
		return null
	var/i = rand(1,hangers.len)
	return hangers[i]


//Hanger schedular manages shuttle that are positioned in intermediate hangers.
//Shuttles need to request scheduling.
datum/hanger_schedular

//List of all shuttles currently beeing scheduled
var/list/shuttle_to_schedule = list()

//Check for each shuttle in the list if they can jump to their final destination
datum/hanger_schedular/proc/process()
	for(var/datum/shuttle/S in shuttle_to_schedule)
		if(S.dest_hanger.can_land_at(S.shuttle) || S.shuttle.SHUTTLE_IDLE)
			S.shuttle.short_jump(dest_hanger)
			shuttle_to_schedule.Remove(S)

datum/hanger_schedular/proc/add_shuttle(datum/shuttle/S, var/obj/hanger/H)
	var/datum/scheduled_shuttle/scheduled_shuttle = new()
	scheduled_shuttle.shuttle = S
	scheduled_shuttle.dest_hanger = H
	scheduled_shuttle.curr_hanger = S.current_hanger
	shuttle_to_schedule += scheduled_shuttle
	var/obj/hanger/J = get_free_space_hanger(S)
	S.short_jump(

dautm/hanger_schedular/proc/remove_shuttle(datum/shuttle/S)
	shuttle_to_schedule -= S

//Wrapper datum
datum/scheduled_shuttle
	var/datum/shuttle/shuttle
	var/obj/hanger/dest_hanger
	var/obj/hanger/curr_hanger