/datum/shuttle/ferry/supply
	var/late_chance = 80
	var/max_late_time = 300.
	var/traveling = 0
	var/obj/hanger/finish_hanger

/datum/shuttle/ferry/supply/short_jump(var/obj/hanger/trg_hanger)
	//Do some checks first
	if(moving_status != SHUTTLE_IDLE)
		return

	if(isnull(location))
		return

	if(isnull(trg_hanger))
		trg_hanger = get_hanger(!location)

	trg_hanger = hanger_check(trg_hanger)

	//Start warmup and do some checks while we are waiting
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		if (at_station() && forbidden_atoms_check(shuttle_turfs))
			//cancel the launch because of forbidden atoms. announce over supply channel?
			moving_status = SHUTTLE_IDLE
			return

	//If we are at the station we will want to leave now.
	//If we are at centcom we want to wait the movetime until we jump
	if(at_station())
		arrive_time = world.time + 5
	else
		arrive_time = world.time + supply_controller.movetime

	//Shuttle is now in transit
	finish_hanger = trg_hanger
	moving_status = SHUTTLE_INTRANSIT
	traveling = 1


/datum/shuttle/ferry/supply/proc/short_jump_finish()
	//We can only arrive late if we are going to the station
	if (!at_station() && prob(late_chance))
		sleep(rand(0,max_late_time))

	display_warning(finish_hanger)
	sleep(50)

	//Move the shuttle
	move(finish_hanger, null, 0)
	if (at_station())
		supply_controller.buy()
	if (!at_station())
		supply_controller.sell()
	if(in_transit)
		moving_status = SHUTTLE_SCHEDULING
	else
		moving_status = SHUTTLE_IDLE

/datum/shuttle/ferry/supply/process()
	..()
	if(traveling)
		if(arrive_time <= world.time)
			short_jump_finish()
			traveling = 0

// returns 1 if the supply shuttle should be prevented from moving because it contains forbidden atoms
/datum/shuttle/ferry/supply/proc/forbidden_atoms_check(var/list/turfs)
	//error("starting forbidden atoms check")
	if (!at_station())
		//error("Not at station check passed")
		return 0	//if badmins want to send mobs or a nuke on the supply shuttle from centcom we don't care
	else
		//error("At station starting check. Checklist is [turfs.len] long.")
		for(var/atom/A in turfs)
			if (supply_controller.forbidden_atoms_check(A))
				//error("Atom [A] was forbidden. Returning with 1")
				return 1
		return 0

//returns 1 if the shuttle is idle and we can still mess with the cargo shopping list
/datum/shuttle/ferry/supply/proc/idle()
	return (moving_status == SHUTTLE_IDLE)

//returns the ETA in minutes
/datum/shuttle/ferry/supply/proc/eta_minutes()
	var/ticksleft = arrive_time - world.time
	return round(ticksleft/600,1)