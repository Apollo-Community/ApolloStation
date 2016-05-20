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
	var/in_transit = 0 //To help with the hanger schedular
	var/priority = 0 //Does this shuttle move other shuttles out of its way ?

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
	error("shuttle [docking_controller_tag] landing at [current_hanger.htag]")
	current_hanger.land_at(src)
	place_shuttle()
	shuttle_ingame = 1

//Initiate the docking controllers by locating them in the game world.
/datum/shuttle/proc/init_docking_controllers()
	if(docking_controller_tag)
		docking_controller = locate(docking_controller_tag)
		if(!istype(docking_controller))
			world << "<span class='danger'>warning: shuttle with docking tag [docking_controller_tag] could not find it's controller!</span>"

//Make a short jump to the target hanger
/datum/shuttle/proc/short_jump(var/obj/hanger/trg_hanger, var/direction)
	if(moving_status != SHUTTLE_IDLE) return

	if(isnull(trg_hanger)) return

	//When jumping to a hanger first look if its full.
	//If its full check if we have priority (aka emergency shuttle).
	//If not see if you can temporary divert to another spot near the station and just squash everything in the way !.
	//If that fails just give up allready !
	if(trg_hanger.can_land_at(src))
		trg_hanger.full = 1
		error("[docking_controller_tag] can land at [trg_hanger.htag]")
	else if (priority)
		hanger_scheduler.divert(trg_hanger.shuttle)
		trg_hanger.full = 1
		error("[docking_controller_tag] can land at [trg_hanger.htag] Priority used")
	else
		var/obj/hanger/J = hanger_controller.get_free_space_hanger(src)
		error("[docking_controller_tag] can not land at [trg_hanger.htag]")
		if(!isnull(J))
			hanger_scheduler.add_shuttle(src, trg_hanger)
			in_transit = 1
			trg_hanger = J
			trg_hanger.full = 1
			error("[docking_controller_tag] diverting to [J.htag]")


	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch
		display_warning(trg_hanger)
		//Give people a few seccond to clear the area
		spawn(50)
			moving_status = SHUTTLE_INTRANSIT //shouldn't matter but just to be safe
			move(trg_hanger, direction, null, 0)

			error("[in_transit]")
			if(!in_transit)
				moving_status = SHUTTLE_IDLE
			else
				moving_status = SHUTTLE_SCHEDULING

//Make a long jump. First go the the interim position and then to the target hanger.
//Wait at the interim position for the indicated time.
/datum/shuttle/proc/long_jump(var/obj/hanger/trg_hanger, var/obj/hanger/interim_hanger, var/travel_time, var/direction)
	//world << "shuttle/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"

	if(moving_status != SHUTTLE_IDLE) return

	if(isnull(trg_hanger)) return

	trg_hanger = hanger_check(trg_hanger)

	if(isnull(interim_hanger))
		interim_hanger = hanger_controller.get_free_interim_hanger(src)

	if(!isnull(interim_hanger) && interim_hanger.can_land_at(src))
		interim_hanger.full = 1
	else
		return

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
			//If we have 5 secconds left inform people in the hanger to gtfo now.
			if((world.time - arrive_time) <= 50)
				display_warning(trg_hanger)

		move(trg_hanger, direction, 0)
		if(!in_transit)
			moving_status = SHUTTLE_IDLE
		else
			moving_status = SHUTTLE_SCHEDULING

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

	//Move and or gib who/what is/are under the arriving shuttle
	move_gib(destination, trg_hanger)
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
	shuttle_turfs = template_controller.PlaceTemplateAt(location, template_path, docking_controller_tag, return_list = 1)

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

//When jumping to a hanger first look if its full.
//If its full check if we have priority (aka emergency shuttle).
//If not see if you can temporary divert to another spot near the station and just squash everything in the way !.
//If that fails just give up allready !
/datum/shuttle/proc/hanger_check(var/obj/hanger/trg_hanger)
	if(trg_hanger.can_land_at(src))
		trg_hanger.full = 1
		error("[docking_controller_tag] can land at [trg_hanger.htag]")
	else if (priority)
		hanger_scheduler.divert(trg_hanger.shuttle)
		trg_hanger.full = 1
		error("[docking_controller_tag] can land at [trg_hanger.htag] Priority used")
	else
		var/obj/hanger/J = hanger_controller.get_free_space_hanger(src)
		error("[docking_controller_tag] can not land at [trg_hanger.htag]")
		if(!isnull(J))
			hanger_scheduler.add_shuttle(src, trg_hanger)
			in_transit = 1
			trg_hanger = J
			trg_hanger.full = 1
			error("[docking_controller_tag] divertin to [trg_hanger.htag]")
	return trg_hanger


/datum/shuttle/proc/move_gib(var/list/turfs, var/obj/hanger/trg_hanger)
	//Move and gib people that are in the are the ship is moving to.
	//If the target hanger is an exerior one only do this to space tiles as we don't want to clip docking arms.

	var/list/filtered_turfs = new/list()
	var/list/to_gib = new/list()
	var/maxy = trg_hanger.y + template_dim[2]

	if(trg_hanger.exterior)
		for(var/turf/T in turfs)
			if(istype(T, /turf/space))
				filtered_turfs += T
	else
		filtered_turfs = turfs

	for(var/turf/T in filtered_turfs)
		var/turf/D = locate(T.x, T.y + (maxy - T.y), T.z)
		for(var/atom/movable/AM as mob|obj in T)
			//Don't move the hanger !
			if(!istype(AM, /obj/hanger))
				AM.Move(D)

		for(var/mob/living/M in T.contents)
			to_gib += M

	for(var/mob/living/M in to_gib)
		M.gib()

	sleep(5)
	for(var/turf/T in filtered_turfs)
		for(var/obj/O in T.contents)
			if(istype(O, /obj/hanger))
				continue
			qdel(O)
			if(!isnull(O))
				del(O)


/datum/shuttle/proc/display_warning(var/obj/hanger/trg_hanger)
	//Move and gib people that are in the are the ship is moving to.
	//If the target hanger is an exerior one only do this to space tiles as we don't want to clip docking arms.
	//radio_announce("WARNING: SHUTTLE LANDING IN THE HANGER BAY CLEAR SHUTTLE AREAS")
	var/list/filtered_turfs = new/list()
	if(trg_hanger.exterior)
		for(var/turf/T in trg_hanger.hanger_area_turfs)
			if(istype(T, /turf/space))
				filtered_turfs += T
	else
		filtered_turfs = trg_hanger.hanger_area_turfs

	//If you get moved out of the way lets be nice and not gib you.
	for(var/turf/T in filtered_turfs)
		for(var/mob/M in T)
			M << "<span class='alert'>You see the shape of a shuttle approaching better move out of the way now!</span>"


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