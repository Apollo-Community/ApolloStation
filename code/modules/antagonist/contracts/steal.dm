/datum/contract/steal
	title = "Retrieve Object of Interest"
	desc = "An object on board the NSS Apollo has caught our attention."
	time_limit = 1800
	reward = 2000

	var/target = null // Type path of the object we want stolen
	var/list/possible_targets = list(
		/obj/item/weapon/rcd,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/amplifier,
		/obj/item/clothing/glasses/welding/superior,
		/obj/item/device/aicard,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped,
		/obj/item/device/mmi/digital/posibrain,
		/obj/item/pod_parts/core)

	var/area/dropoff = null // The area where the item must be dropped off at
	var/area/list/dropoff_areas = list(
		/area/security/vacantoffice,
		/area/maintenance/disposal,
		/area/quartermaster/storage,
		/area/storage/tech,
		/area/construction,
		/area/maintenance/incinerator,
		/area/storage/emergency,
		/area/library)

/datum/contract/steal/New()
	..()

	target = get_target()
	dropoff = locate(pick(dropoff_areas))
	// much easier to pick a new dropoff area rather than a new target
	while((locate(target) in dropoff))
		dropoff = locate(pick(dropoff_areas))

	if(!dropoff || !target)
		if(ticker.current_state != 1)
			qdel(src)
		return

	set_details()

/datum/contract/steal/set_details()
	var/obj/O = new target()
	title = "Steal \the [O.name]"
	desc = "We've taken an interest in \the [O.name]. [pick(list("Deliver", "Drop off"))] \the [O.name] to \the [dropoff.name], where one of our agents will retrieve it."
	qdel(O)

// Steal contracts only end unsuccessfully by time expiration
/datum/contract/steal/check_completion()
	if(workers.len == 0)	return

	var/obj/O = locate(target) in dropoff
	var/mob/list/audience = viewers(O)
	if(O && audience.len == 0)
		var/mob/living/completer = null
		for(var/mob/M in workers)
			if(M.client.key == O.fingerprintslast)
				completer = M
				break
		end(1, completer)
		qdel(O)

/datum/contract/steal/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/steal/C in (uplink.contracts - src))
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/steal/proc/get_target()
	possible_targets -= get_taken_targets()

	var/list/candidates = list()
	for(var/path in possible_targets)
		if(locate(path)) // the target item must be on the station
			candidates += path
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

/datum/contract/steal/novelty
	title = "Steal Symbolic Item"
	desc = "There's an object of symbolic value we want removed."

	reward = 1500
	possible_targets = list(
		/obj/item/weapon/melee/chainofcommand,
		/obj/item/clothing/under/rank/head_of_personnel_whimsy,
		/obj/item/weapon/reagent_containers/food/drinks/flask,
		/obj/item/weapon/holder/runtime)
