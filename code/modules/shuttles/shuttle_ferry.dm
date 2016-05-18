#define DOCK_ATTEMPT_TIMEOUT 200	//how long in ticks we wait before assuming the docking controller is broken or blown up.

/datum/shuttle/ferry
	var/location	//0 = at area_station, 1 = at area_offsite
	var/direction = 0	//0 = going to station, 1 = going to offsite.
	var/process_state = IDLE_STATE
	var/in_use = null	//tells the controller whether this shuttle needs processing
	var/move_time = 0		//the time spent in the transition area
	var/transit_direction = null	//needed for area/move_contents_to() to properly handle shuttle corners - not exactly sure how it works.
	var/obj/hanger/hanger_station
	var/obj/hanger/hanger_offsite
	var/pod = 0

	//TODO: change location to a string and use a mapping for area and dock targets.
	var/dock_target_station
	var/dock_target_offsite

	var/last_dock_attempt_time = 0

//Ferries always have two stops so they must be ingame at round start
/datum/shuttle/ferry/init_templates()
	//What is our home base ?
	if(location == 0)
		starting_hanger = hanger_station
	else
		starting_hanger = hanger_offsite

	..()

//Ferries have a simple short jump
//Find out if we have a location, if so determin where we are going.
//Ask the hanger if it allready has a shuttle in it. if not proceed with the jump
//Call super to finsh the standart short jump
/datum/shuttle/ferry/short_jump(var/obj/hanger/trg_hanger, var/direction)
	if(isnull(location))
		return

	if(isnull(trg_hanger))
		trg_hanger = get_hanger(!location)

	if(isnull(direction))
		direction = !location
	..(trg_hanger, direction)

//Ferry long jump
//Find out if we have a location, if so determin where we are going.
//Call super with your destination and bluespace hanger
/datum/shuttle/ferry/long_jump(var/obj/hanger/trg_hanger, var/obj/hanger/interim_hanger, var/travel_time, var/direction)
	if(isnull(location))
		return

	if(isnull(trg_hanger))
		trg_hanger = get_hanger(!location)

	direction = !location
	..(trg_hanger, interim_hanger, travel_time, direction)


//Ferries have a few things that need to be done afther the standart move.
//Call super with destination and change the location where are at accordingly
/datum/shuttle/ferry/move(var/obj/hanger/trg_hanger, var/direction = null, var/long_j)
	..(trg_hanger, null, long_j)

	//if this is a long_jump retain the location we were last at until we get to the new one
	//First check if we even have an interum location
	if(!long_j)
		location = !location

//Docking magic
/datum/shuttle/ferry/dock()
	..()
	last_dock_attempt_time = world.time

//What hanger is at this location ?
/datum/shuttle/ferry/proc/get_hanger(location_id)
	if(isnull(location_id))
		location_id = location

	if(location_id)
		return hanger_offsite
	else
		return hanger_station

/*
	Please ensure that long_jump() and short_jump() are only called from here. This applies to subtypes as well.
	Doing so will ensure that multiple jumps cannot be initiated in parallel.
*/
/datum/shuttle/ferry/proc/process()
	switch(process_state)
		if (WAIT_LAUNCH)
			if (skip_docking_checks() || docking_controller.can_launch() || (docking_controller_tag == "escape_shuttle"))
				if (move_time > 0)
					long_jump(null, null, move_time, transit_direction)
				else
					short_jump()

				process_state = WAIT_ARRIVE

		if (FORCE_LAUNCH)
			if (move_time && pod)
				long_jump(null, null, move_time, transit_direction)
			else
				short_jump()

			process_state = WAIT_ARRIVE

		if (WAIT_ARRIVE)
			if (moving_status == SHUTTLE_IDLE && !in_transit)
				dock()
				in_use = null	//release lock
				process_state = WAIT_FINISH

		if (WAIT_FINISH)
			if (skip_docking_checks() || docking_controller.docked() || world.time > last_dock_attempt_time + DOCK_ATTEMPT_TIMEOUT)
				process_state = IDLE_STATE
				arrived()

/datum/shuttle/ferry/current_dock_target()
	var/dock_target
	if (!location)	//station
		dock_target = dock_target_station
	else
		dock_target = dock_target_offsite
	return dock_target


/datum/shuttle/ferry/proc/launch(var/user)
	if (!can_launch()) return 0
	in_use = user	//obtain an exclusive lock on the shuttle

	process_state = WAIT_LAUNCH
	undock()
	return 1

/datum/shuttle/ferry/proc/force_launch(var/user)
	if (!can_force()) return 0

	in_use = user	//obtain an exclusive lock on the shuttle

	process_state = FORCE_LAUNCH
	return 1

/datum/shuttle/ferry/proc/cancel_launch(var/user)
	if (!can_cancel()) return

	moving_status = SHUTTLE_IDLE
	process_state = WAIT_FINISH
	in_use = null

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	spawn(10)
		dock()

	return

/datum/shuttle/ferry/proc/can_launch()
	if (moving_status != SHUTTLE_IDLE)
		return 0

	if (in_use)
		return 0

	var/obj/hanger/H = get_hanger(!location)
	if (!H.can_land_at(src))
		return 0
	return 1

/datum/shuttle/ferry/proc/can_force()
	var/obj/hanger/H = get_hanger(!location)
	if (!H.can_land_at(src))
		return 0

	if (moving_status == SHUTTLE_IDLE && process_state == WAIT_LAUNCH)
		return 1

/datum/shuttle/ferry/proc/can_cancel()
	if (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH || process_state == FORCE_LAUNCH)
		return 1
	return 0

//returns 1 if the shuttle is getting ready to move, but is not in transit yet
/datum/shuttle/ferry/proc/is_launching()
	return (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH || process_state == FORCE_LAUNCH)

//This gets called when the shuttle finishes arriving at it's destination
//This can be used by subtypes to do things when the shuttle arrives.
/datum/shuttle/ferry/proc/arrived()
	return	//do nothing for now

/datum/shuttle/ferry/proc/at_station()
	return (!location)
