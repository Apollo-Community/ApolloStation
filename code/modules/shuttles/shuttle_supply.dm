/datum/shuttle/ferry/supply
	var/late_chance = 80
	var/max_late_time = 300

/datum/shuttle/ferry/supply/short_jump(var/datum/hanger/trg_hanger)
	//Do some checks first
	if(moving_status != SHUTTLE_IDLE)
		return

	if(isnull(location))
		return

	if(isnull(trg_hanger))
		trg_hanger = get_hanger(!location)

	//Check with the hanger if its full and occupy it if its not.
	if(!trg_hanger.can_land_at(src))
		return
	else
		trg_hanger.full = 1

	//Start warmup and do some checks while we are waiting
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		if (at_station() && forbidden_atoms_check())
			//cancel the launch because of forbidden atoms. announce over supply channel?
			moving_status = SHUTTLE_IDLE
			return

		/*
		Broken somehow. Shuttle now buys stuff when at station.
		if (!at_station())	//at centcom
			world << "Start buy stuff"
			supply_controller.buy()
		*/
	//If we are at the station we will want to leave now.
	//If we are at centcom we want to wait the movetime until we jump
	if(at_station())
		arrive_time = world.time + 5
	else
		arrive_time = world.time + supply_controller.movetime

	//Shuttle is now in transit
	moving_status = SHUTTLE_INTRANSIT

	//Waiting until we can move
	while (world.time <= arrive_time)
		sleep(5)

	//Is the shuttle going to arrive late ?
	//We can only arrive late if we are going to the station
	if (!at_station() && prob(late_chance))
		sleep(rand(0,max_late_time))

	//Move the shuttle
	move(trg_hanger, null, 0)

	if (at_station())
		supply_controller.buy()
	if (!at_station())
		supply_controller.sell()

	moving_status = SHUTTLE_IDLE

// returns 1 if the supply shuttle should be prevented from moving because it contains forbidden atoms
/datum/shuttle/ferry/supply/proc/forbidden_atoms_check()
	if (!at_station())
		return 0	//if badmins want to send mobs or a nuke on the supply shuttle from centcom we don't care
	else
		return 0
	//return supply_controller.forbidden_atoms_check(get_location_area())
	//return 0

//returns 1 if the shuttle is idle and we can still mess with the cargo shopping list
/datum/shuttle/ferry/supply/proc/idle()
	return (moving_status == SHUTTLE_IDLE)

//returns the ETA in minutes
/datum/shuttle/ferry/supply/proc/eta_minutes()
	var/ticksleft = arrive_time - world.time
	return round(ticksleft/600,1)
