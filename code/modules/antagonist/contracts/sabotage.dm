// Sabotage can mean a lot, so this contract doesn't try to generalize anything.
// Different types of sabotage will be different subtypes

/datum/contract/sabotage
	title = "!BASE! Sabotage Station Efforts"
	desc = "screw sum shit up"
	time_limit = 3600
	max_workers = 1
	max_contracts = 1
	reward = 2000

// APC POWER SUPPLY SABOTAGE //

// Cut an APC off from its external power source
/datum/contract/sabotage/apc_supply
	title = "Sabotage APC power supply"
	desc = "Cut off an APC from it's external power source"
	time_limit = 1800
	max_contracts = 2
	reward = 750 // damn easy job

	var/obj/machinery/power/apc/target = null
	var/list/areas = list(
		/area/crew_quarters/observe,
		/area/hallway/secondary/exit,
		/area/medical/reception,
		/area/crew_quarters/bar,
		/area/security/lobby,
		/area/hallway/primary/aft_port,
		/area/storage/primary
		)

/datum/contract/sabotage/apc_supply/New()
	. = ..()
	if(!.)	return

	target = get_target()
	if(!target)
		qdel(src)
		return

	set_details()

/datum/contract/sabotage/apc_supply/set_details()
	title = "Sabotage \the [target.name]"
	desc = "[pick(list("Some simple sabotage is in order", "We want to see [target.area.name] in the dark", "A simple vurnerability demonstration"))]. [pick(list("Sabotage \the [target.name] by disabling its external power source", "Cut \the [target.name] off from its external power source"))]."
	informal_name = "Sabotage \the [target.name] by disabling its external power source"

/datum/contract/sabotage/apc_supply/check_completion()
	if(workers.len == 0)	return

	if(!target.main_status)
		end(1, workers[1])

/datum/contract/sabotage/apc_supply/proc/get_taken_areas()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/sabotage/apc_supply/C in (faction.contracts + faction.completed_contracts))
		if(istype(C) && C.target)	taken += C.target.area.type
	return taken

/datum/contract/sabotage/apc_supply/proc/get_target()
	areas -= get_taken_areas()

	var/list/obj/machinery/power/apc/candidates = list()
	for(var/path in areas)
		var/area/A = locate(path)
		var/obj/machinery/power/apc/apc = A.apc
		if(A && (apc && apc.main_status)) // don't offer a sabotage contract on an area APC that's lost the power source
			candidates += A.apc
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

// Sabotage APCs in high security areas
/datum/contract/sabotage/apc_supply/hard
	max_contracts = 1
	reward = 1250

	areas = list(
		/area/bridge,
		/area/crew_quarters/captain,
		/area/server,
		/area/security/main,
		/area/turret_protected/ai_server_room,
		/area/tcomms/computer,
		/area/tcomms/chamber
		)

// DISABLE SECURITY CAMERAS //

// Disable some number of security cameras
/datum/contract/sabotage/cameras
	title = "Sabotage Security Cameras"
	desc = "Disable a number of security cameras"
	time_limit = 1800
	max_contracts = 1
	reward = 1000

	var/disabled_at_start = 0
	var/to_disable = 0

/datum/contract/sabotage/cameras/New()
	. = ..()
	if(!.)	return

	for(var/obj/machinery/camera/C in world)
		if(C.z == 3 && (!C.status || (C.stat & BROKEN)))
			disabled_at_start++

	if(disabled_at_start >= 60) // if 60 cameras have been destroyed already, that's more than enough
		qdel(src)
		return 0

	to_disable = rand(2, 10)
	reward = 150*to_disable

	set_details()

/datum/contract/sabotage/cameras/set_details()
	desc = "[pick(list("Surveillance sucks", "\The [station_name()] has [to_disable] too many cameras", "Time to get rid of the spying eye"))]. Disable at least [to_disable] security cameras."
	informal_name = "Disable [to_disable] security cameras"

/datum/contract/sabotage/cameras/check_completion()
	if(workers.len == 0)	return

	var/disabled_count = 0
	for(var/obj/machinery/camera/C in world)
		if(C.z == 3 && (!C.status || (C.stat & BROKEN)))
			disabled_count++
	disabled_count -= disabled_at_start

	if(disabled_count >= to_disable)
		end(1, workers[1])

// DEPRESSURIZE AREA //

// Drop the area's pressure to < 20kPa
/datum/contract/sabotage/depressurize
	title = "Cause Depressurization Event"
	desc = "Depressurize an area"
	time_limit = 2700
	min_notoriety = 3
	reward = 1500

	var/area/target_area = null
	var/areas = list(
		/area/crew_quarters/bar,
		/area/medical/sleeper,
		/area/crew_quarters/diner,
		/area/security/main,
		/area/bridge,
		/area/ai_monitored/storage/eva
		)

/datum/contract/sabotage/depressurize/New()
	. = ..()
	if(!.)	return

	target_area = get_area()
	if(!target_area)
		qdel(src)
		return

	set_details()

/datum/contract/sabotage/depressurize/set_details()
	title = "Depressurize \The [target_area.name]"
	desc = "[pick(list("Love is in the air... get rid of it", "Help the poor crew overcome their phobia of vacuums"))]. Drop the air pressure to below 20kPa in \The [target_area.name]."
	informal_name = "Depressurize \The [target_area.name]"

/datum/contract/sabotage/depressurize/check_completion()
	if(workers.len == 0)	return

	var/turf/simulated/floor/F = (locate(/turf/simulated/floor) in target_area)
	if( F ) // really hope they haven't done their job TOO well
		var/datum/gas_mixture/G = F.return_air()
		if( G && G.return_pressure() < 20 )
			end(1, workers[1])
	else // but y'kno, if they have...
		if(locate(/turf/space) in target_area)
			end(1, workers[1])

/datum/contract/sabotage/depressurize/proc/get_taken_areas()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/sabotage/depressurize/C in (faction.contracts + faction.completed_contracts))
		if(istype(C) && C.target_area)	taken += C.target_area.type
	return taken

/datum/contract/sabotage/depressurize/proc/get_area()
	areas -= get_taken_areas()

	var/list/area/candidates = list()
	for(var/path in areas)
		var/area/A = locate(path)
		if(!A.master_air_alarm)	continue
		var/turf/T = get_turf(A.master_air_alarm)
		var/datum/gas_mixture/G = T.return_air()
		if(G && G.return_pressure() < 20)	continue // don't pick areas that are depressurized already

		candidates += locate(path)
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise