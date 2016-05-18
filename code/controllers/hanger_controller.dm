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


//Hanger schedular manages shuttle that are positioned in intermediate hangers.
//Shuttles need to request scheduling.
datum/hanger_schedular

//List of all shuttles currently beeing scheduled
var/list/shuttle_to_schedule = list()

datum/hanger_schedular/proc/process()
	for(var/datum/shuttle/S in shuttle_to_schedule)
		if(S.dest_hanger.can_land_at(S.shuttle))
			S.shuttle.short_jump(dest_hanger)
		else(

datum/hanger_schedular/proc/add_shuttle(datum/shuttle/S, var/obj/hanger/H)
	var/datum/shuttle/scheduled_shuttle = S
	scheduled_shuttle.dest_hanger = H
	scheduled_shuttle.curr_hanger = S.current_hanger
	shuttle_to_schedule += scheduled_shuttle

dautm/hanger_schedular/proc/remove_shuttle(datum/shuttle/S)
	shuttle_to_schedule -= S

//Wrapper datum
datum/scheduled_shuttle
	var/datum/shuttle/shuttle
	var/obj/hanger/dest_hanger
	var/obj/hanger/curr_hanger