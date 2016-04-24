//These lists are populated in /datum/shuttle_controller/New()
//Shuttle controller is instantiated in master_controller.dm.

//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE
	var/list/template_dim
	var/area/template_area
	var/template_path
	var/list/dock_coord_interim
	var/tag_interim
	var/list/shuttle_turfs
	var/shuttle_ingame = 0
	var/datum/hanger/current_hanger
	var/docking_controller_tag	//tag of the controller used to coordinate docking
	var/datum/computer/file/embedded_program/docking/docking_controller	//the controller itself. (micro-controller, not game controller)
	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping

/datum/shuttle/proc/init_templates()
	if(!isnull(template_area))
		shuttle_turfs = get_area_turfs(template_area.type)
	else
		world << "<span class='danger'>warning: [docking_controller_tag] shuttle area could not be located </span>"

	template_dim = template_controller.GetTemplateSize(template_path)
	/*
	var/datum/dim_min_max/dims = get_dim_and_minmax(shuttle_turfs)
	template_dim = list(dims.dim_x , dims.dim_y)
	if(template_dim[1] % 2)
		template_dim[1] = template_dim[1] + 1
	if(template_dim[2] % 2)
		template_dim[2] = template_dim[2] + 1
	//annoying blue space ugh
	if(!isnull(tag_interim))
		var/obj/locObj = locate(tag_interim)
		dock_coord_interim = list(locObj.x, locObj.y, locObj.z)
	*/

//Initiate the docking controllers by locating them in the game world.
//If there are no.. do nothing ?
/datum/shuttle/proc/init_docking_controllers()
	if(docking_controller_tag)
		docking_controller = locate(docking_controller_tag)
		if(!istype(docking_controller))
			world << "<span class='danger'>warning: shuttle with docking tag [docking_controller_tag] could not find it's controller!</span>"

//Make a short jump to the target hanger
/datum/shuttle/proc/short_jump(var/datum/hanger/trg_hanger, var/direction)
	error("shuttle [template_path] making short jump to [trg_hanger.tag]")
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
		move(trg_hanger, null, 0)
		moving_status = SHUTTLE_IDLE

//Make a long jump. First go the the interim position and then to the target hanger.
//Wait at the interim position for the indicated time.
/datum/shuttle/proc/long_jump(var/datum/hanger/trg_hanger, var/list/coord_interim, var/travel_time, var/direction)
	//world << "shuttle/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"
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

		arrive_time = world.time + travel_time*10
		moving_status = SHUTTLE_INTRANSIT
		move(trg_hanger, direction, null, 1)


		while (world.time < arrive_time)
			sleep(5)

		move(trg_hanger, direction, null, 0)
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
	if (!docking_controller)
		return
	docking_controller.initiate_undocking()

/datum/shuttle/proc/current_dock_target()
	return null

/datum/shuttle/proc/skip_docking_checks()
	if (!docking_controller || !current_dock_target())
		return 1	//shuttles without docking controllers or at locations without docking ports act like old-style shuttles
	return 0

//Arguments:
//trg_hanger - The hanger we are going to jump to, must be a datum/hanger type
//direction - the direction we are jumping (not shure if this matters)
//long_j - Is this called via long jump ? (needed for hanger assigment and hanger calls).
//Returns:
//Nothing
//Note:
//A note to anyone overriding move in a subtype. move() must absolutely not, under any circumstances, fail to move the shuttle.
//If you want to conditionally cancel shuttle launches, that logic must go in short_jump() or long_jump()
//world << "move_shuttle() called for [shuttle_tag] leaving [current_hanger.tag] en route to [trg_hanger.tag]."
/datum/shuttle/proc/move(var/datum/hanger/trg_hanger, var/direction=null, var/long_j)

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	//Do stuff to destination turfs this gets a square.. not so nice because we will gib people in it
	var/list/destination = get_turfs_square(trg_hanger.loc.x_pos, trg_hanger.loc.y_pos, trg_hanger.loc.z_pos, template_dim[1] , template_dim[2] )
	//error("Move command called by [template_path] to [trg_hanger.tag] there are destination [destination.len] turfs in the shuttle destination area")
	//error("The destination area is centered upon [trg_hanger.loc.x_pos] - [trg_hanger.loc.y_pos] - [trg_hanger.loc]")

	//Move and or gib who/what is/are under the arriving shuttle
	move_gib(destination, trg_hanger.exterior)

	//Tell the hanger a shuttle is landing at it if we are not jumping to blue space
	if(!long_j)
		//error("[template_path] is going to call the hanger")
		//error("[shuttle_turfs.len] is the size of the shuttle")
		trg_hanger.land_at(src)

	//Are we physycally in the game yet ?
	if(!shuttle_ingame)
		//Make it so at the location you want to be
		place_shuttle(trg_hanger)
		shuttle_ingame = 1
	else
		shuttle_turfs = filter_space(shuttle_turfs)
		shuttle_turfs = move_turfs_to_turfs(shuttle_turfs, destination, direction=direction)

	//move_gib(destination, trg_hanger)

	//Tell the hanger you took of from that you've taken off from it.
	current_hanger.take_off()
	//The hanger that you went to is now your current if you are not jumping to blue space
	//If so assign a special blue space hanger (this is hacky)
	if(!long_j)
		current_hanger = trg_hanger
	else
		current_hanger = blue_hanger

	//Shake effect
	shake_effect(shuttle_turfs)

	//Check and update powered systems on the shuttle
	power_check(shuttle_turfs)
	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)

/datum/shuttle/proc/place_shuttle(var/datum/hanger/trg_hanger)
	if(isnull(trg_hanger) || shuttle_ingame) return
	shuttle_turfs = move_turfs_to_turfs (shuttle_turfs, get_turfs_square(trg_hanger.loc.x_pos, trg_hanger.loc.y_pos, trg_hanger.loc.z_pos, template_dim[1], template_dim[2]))
	//copy_list_contents_to(shuttle_turfs, get_turfs_square(trg_hanger.loc.x_pos, trg_hanger.loc.y_pos, trg_hanger.loc.z_pos, template_dim[1], template_dim[2]))
	shuttle_ingame = 1

//Shake effect
/datum/shuttle/proc/shake_effect(var/list/turfs)
	for(var/turf/T in turfs)
		for(var/mob/M in T)
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
	var/throwy = world.maxy
	var/list/filtered_turfs = new/list()
	if(exterior)
		for(var/turf/T in turfs)
			if(istype(T, /turf/space))
				filtered_turfs += T
	else
		filtered_turfs = turfs

	for(var/turf/T in filtered_turfs)
		if(T.y < throwy)
			throwy = T.y

	for(var/turf/T in filtered_turfs)
		var/turf/D = locate(T.x, throwy - 1, 1)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)

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