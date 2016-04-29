//These lists are populated in /datum/shuttle_controller/New()
//Shuttle controller is instantiated in master_controller.dm.

//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE
	var/list/template_dim
	var/template_path
	var/list/dock_coord_interim
	var/tag_interim
	var/list/shuttle_turfs
	var/shuttle_ingame = 0
	var/obj/hanger/current_hanger
	var/obj/hanger/interim_hanger
	var/obj/hanger/starting_hanger
	var/docking_controller_tag	//tag of the controller used to coordinate docking
	var/datum/computer/file/embedded_program/docking/docking_controller	//the controller itself. (micro-controller, not game controller)
	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping

/datum/shuttle/proc/init_templates()
	if(isnull(template_path))
		world << "<span class='danger'>warning: [docking_controller_tag] shuttle template could not be located. </span>"
	template_dim = template_controller.GetTemplateSize(template_path)

	if(isnull(starting_hanger))
		starting_hanger = hanger_controller.ger_free_starting_hanger(src)
		if(isnull(starting_hanger))
			world << "<span class='danger'>warning: [docking_controller_tag] could not find a hanger to start at. </span>"
	//Place down the template at the right spot further down in this process this will also aquere the right turfs for us.
	current_hanger = starting_hanger
	current_hanger.full = 1
	current_hanger.land_at(src)
	place_shuttle()
	shuttle_ingame = 1
	error("current hanger = [current_hanger.htag]")


//Initiate the docking controllers by locating them in the game world.
/datum/shuttle/proc/init_docking_controllers()
	if(docking_controller_tag)
		docking_controller = locate(docking_controller_tag)
		if(!istype(docking_controller))
			world << "<span class='danger'>warning: shuttle with docking tag [docking_controller_tag] could not find it's controller!</span>"

//Make a short jump to the target hanger
/datum/shuttle/proc/short_jump(var/obj/hanger/trg_hanger, var/direction)
	error("shuttle [template_path] making short jump to [trg_hanger.htag]")
	if(moving_status != SHUTTLE_IDLE) return

	if(isnull(trg_hanger)) return

	if(trg_hanger.can_land_at(src))
		trg_hanger.full = 1
	else
		return

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe
		error("shuttle [template_path] jumpint now to [trg_hanger.tag]")
		move(trg_hanger, direction, null, 0)
		moving_status = SHUTTLE_IDLE

//Make a long jump. First go the the interim position and then to the target hanger.
//Wait at the interim position for the indicated time.
/datum/shuttle/proc/long_jump(var/obj/hanger/trg_hanger, var/obj/hanger/interim_hanger, var/travel_time, var/direction)
	//world << "shuttle/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"
	error("long jump called in shuttle [template_path]")

	if(moving_status != SHUTTLE_IDLE) return
	error("moving status check passed")

	if(isnull(trg_hanger)) return
	error("trg_hanger check passed")
	error("target hanger status [trg_hanger.full]")
	error("target hanger can_land_at returns  [trg_hanger.can_land_at(src)]")
	if(!trg_hanger.can_land_at(src)) return
	trg_hanger.full = 1
	error("Can we land at the trg_hanger ?")

	if(isnull(interim_hanger))
		interim_hanger = hanger_controller.get_free_interim_hanger(src)
	error("what is our interim hanger ? [interim_hanger.htag]")

	if(!isnull(interim_hanger) && interim_hanger.can_land_at(src))
		interim_hanger.full = 1
	error("interim hanger can_land_at passed")

	error("shuttle/ferry/shuttle [docking_controller_tag]: departing=[current_hanger.htag], destination=[trg_hanger.htag], interim=[interim_hanger.htag], travel_time=[travel_time]")

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		arrive_time = world.time + travel_time*10
		moving_status = SHUTTLE_INTRANSIT
		//Needs to have interim_hanger
		move(interim_hanger, direction, 1)


		while (world.time < arrive_time)
			sleep(5)

		move(trg_hanger, direction, 0)
		moving_status = SHUTTLE_IDLE

//Dock at you current dock.
/datum/shuttle/proc/dock()
	if (!docking_controller)
		return

	var/dock_target = current_dock_target()
	if (!dock_target)
		return
	docking_controller.initiate_docking(dock_target)

/datum/shuttle/proc/undock()
	error("undock called")
	if (!docking_controller)
		return
	docking_controller.initiate_undocking()
	error("init undocking called")

/datum/shuttle/proc/current_dock_target()
	return null

/datum/shuttle/proc/skip_docking_checks()
	if (!docking_controller || !current_dock_target())
		return 1	//shuttles without docking controllers or at locations without docking ports act like old-style shuttles
	return 0

//Arguments:
//trg_hanger - The hanger we are going to jump to, must be a datum/hanger type
//direction - the direction we are jumping (not shure if this matters)
//Returns:
//Nothing
//Note:
//A note to anyone overriding move in a subtype. move() must absolutely not, under any circumstances, fail to move the shuttle.
//If you want to conditionally cancel shuttle launches, that logic must go in short_jump() or long_jump()
//world << "move_shuttle() called for [shuttle_tag] leaving [current_hanger.tag] en route to [trg_hanger.tag]."
/datum/shuttle/proc/move(var/obj/hanger/trg_hanger, var/direction=null, var/long_j)

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	//Do stuff to destination turfs this gets a square.. not so nice because we will gib people in it
	var/list/destination = get_turfs_square(trg_hanger.x, trg_hanger.y, trg_hanger.z, template_dim[1] , template_dim[2] )
	error("Move command called by [template_path] to [trg_hanger.htag] the destination has [destination.len] turfs")
	error("The destination area is centered upon [trg_hanger.x] - [trg_hanger.y] - [trg_hanger.loc]")

	//Move and or gib who/what is/are under the arriving shuttle
	move_gib(destination, trg_hanger.exterior)
	trg_hanger.land_at(src)
	shuttle_turfs = move_turfs_to_turfs(shuttle_turfs, destination, direction=direction)
	current_hanger.take_off()
	current_hanger.full = 0
	current_hanger = trg_hanger
	shake_effect(shuttle_turfs)

	//Check and update powered systems on the shuttle
	power_check(shuttle_turfs)
	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)

/datum/shuttle/proc/place_shuttle()
	if(isnull(current_hanger) || shuttle_ingame) return
	shuttle_ingame = 1
	var/turf/location = get_corner_turf(current_hanger.x, current_hanger.y, current_hanger.z, template_dim[1], template_dim[2])
	//error("the shuttle [docking_controller_tag] has target hanger [current_hanger] at [current_hanger.x], [current_hanger.y], [current_hanger.z]")

	shuttle_turfs = template_controller.PlaceTemplateAt(location, template_path, docking_controller_tag, return_list = 1)
	//error("shuttle [docking_controller_tag] placed via template the turfs contain [shuttle_turfs.len] turfs and are centered around [trg_hanger.loc.x_pos] - [trg_hanger.loc.y_pos] - [trg_hanger.loc.z_pos]")

//Shake effect
/datum/shuttle/proc/shake_effect(var/list/turfs)
	var/area/A
	for(var/turf/T in turfs)
		A = T.loc
		for(var/mob/M in T)
			A.Entered(M)
			//Have to find a fix for this
			//destination.Entered(M)
			if(M.client)
				spawn(0)
					if(M.buckled)
						M << "<span class='alert'>Sudden acceleration presses you into your chair!</span>"
						shake_camera(M, 3, 1)
					else
						M << "<span class='alert'>The floor lurches beneath you!</span>"
						shake_camera(M, 10, 1)
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)


/datum/shuttle/proc/move_gib(var/list/turfs, var/exterior)
	//Move and gib people that are in the are the ship is moving to.
	//If the target hanger is an exerior one only do this to space tiles as we don't want to clip docking arms.

	var/list/filtered_turfs = new/list()
	if(exterior)
		for(var/turf/T in turfs)
			if(istype(T, /turf/space))
				filtered_turfs += T
	else
		filtered_turfs = turfs
//	var/throwy = world.maxy
//	for(var/turf/T in filtered_turfs)
//		if(T.y < throwy)
//			throwy = T.y

//	for(var/turf/T in filtered_turfs)
//		var/turf/D = locate(T.x, throwy - 1, 1)
//		for(var/atom/movable/AM as mob|obj in T)
//			AM.Move(D)

	//If you get moved out of the way lets be nice and not gib you.
	for(var/turf/T in filtered_turfs)
		for(var/mob/living/carbon/bug in T.contents)
			bug.gib()

		for(var/mob/living/simple_animal/pest in T.contents)
			pest.gib()

/datum/shuttle/proc/power_check(var/list/turfs)
	var/update_power = 0
	for(var/turf/T in turfs)
		for(var/obj/machinery/power/P in T)
			update_power = 1
			break

		for(var/obj/structure/cable/C in T)
			update_power = 1
			break

	if(update_power)
		makepowernets()