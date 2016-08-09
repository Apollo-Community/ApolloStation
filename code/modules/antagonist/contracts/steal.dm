/datum/contract/steal
	title = "Retrieve Object of Interest"
	desc = "An object on board the NOS Apollo has caught our attention."
	time_limit = 1800
	max_contracts = 3
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
		/obj/item/pod_parts/core
	)

	var/area/dropoff = null // The area where the item must be dropped off at
	var/area/list/dropoff_areas = list(
		/area/library,
		/area/crew_quarters/locker,
		/area/crew_quarters/observe,
		/area/security/vacantoffice2,
		/area/maintenance/incinerator,
		/area/maintenance/disposal
	)

	var/dropoff_time

/datum/contract/steal/New()
	. = ..()
	if(!.)	return

	target = get_target()
	var/list/candidate_areas = dropoff_areas.Copy()
	dropoff = locate(pick(dropoff_areas))
	// much easier to pick a new dropoff area rather than a new target
	while((locate(target) in dropoff) && candidate_areas.len)
		candidate_areas -= dropoff.type
		dropoff = locate(pick(candidate_areas))

	if(!dropoff || !target)
		qdel(src)
		return

	dropoff_time = rand(4, 6) * 600 // 4-6 minutes

	set_details()

/datum/contract/steal/set_details()
	var/obj/O = new target()
	var/dropoff_interval = (contract_start + time_limit - dropoff_time)
	title = "Steal \the [O.name]"
	desc = "We've taken an interest in \the [O.name]. [pick(list("Deliver", "Drop off"))] \the [O.name] to \the [dropoff.name], where one of our agents can retrieve it after [worldtime2text(dropoff_interval)]. Nobody can see the target when our agent retrieves it."
	informal_name = "Steal \the [O.name] and deliver it to \the [dropoff.name]"
	qdel(O)

// Steal contracts only end unsuccessfully by time expiration
/datum/contract/steal/check_completion()
	if(workers.len == 0)	return
	var/dropoff_interval = (contract_start + time_limit - dropoff_time) // dropoff_time before the contract expires
	if(world.time < dropoff_interval)	return

	var/obj/O = locate(target) in dropoff
	if(!O) // locate sucks >:(
		for(var/obj/P in dropoff)
			O = locate(target) in P
			if(O)	break
	if(!O)	return

	var/mob/list/audience = viewers(O)
	for(var/mob/M in audience)
		if( ( !issilicon(M) && !ishuman(M) ) || isnull(M.client) )	audience -= M // only crew players matter. mice and the likes can freak out all they like when stuff disappears before their very eyes

	if(audience.len == 0)
		var/mob/living/completer = null
		for(var/mob/M in workers)
			if(M.client.key == O.fingerprintslast)
				completer = M
				break
		end(1, completer)
		playsound(O.loc, 'sound/effects/pop1.ogg', 80, 1)
		qdel(O)

/datum/contract/steal/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/steal/C in (faction.contracts + faction.completed_contracts))
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/steal/proc/get_target()
	possible_targets -= get_taken_targets()

	var/list/candidates = list()
	for(var/path in possible_targets)
		if(locate(path)) // the target item must be there when the game starts
			candidates += path
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

/datum/contract/steal/novelty
	title = "Steal Symbolic Item"
	desc = "There's an object of symbolic value we want removed."
	max_contracts = 1
	reward = 1500

	possible_targets = list(
		/obj/item/weapon/melee/chainofcommand,
		/obj/item/clothing/under/rank/head_of_personnel_whimsy,
		/obj/item/weapon/reagent_containers/food/drinks/flask,
		/obj/item/weapon/holder/runtime
		)
