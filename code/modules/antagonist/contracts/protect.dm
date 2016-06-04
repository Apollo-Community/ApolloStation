// Protect a kill target, essentially an inverse kill contract
/datum/contract/protect
	title = "Protect the Target"
	desc = "We cannot afford for this dude to die until the contract expires."
	time_limit = 3600
	max_contracts = 2
	max_workers = 1
	reward = 2000
	
	var/datum/mind/target = null

/datum/contract/protect/New()
	. = ..()
	if(!.)	return

	target = get_target()
	if(!target)
		qdel(src)
		return

	// less cash for protecting heads because they're already hard targets
	if(target.assigned_role in command_positions)
		reward *= 0.6

	set_details()

/datum/contract/protect/set_details()
	title = "[pick(list("Protect", "Safeguard", "Guard", "Shield"))] [target.current.real_name]"
	desc = "[target.current.real_name], the [target.assigned_role] [pick(list("is a key component in our plans", "cannot be allowed to come to harm", "should be staying alive a little longer"))]. [pick(list("Make sure they don't die... until the specified time", "We know somebody wants them dead, so make sure it doesn't happen", "Protect them"))]."
	informal_name = "Protect [target.current.real_name], the [target.assigned_role]"

/datum/contract/protect/can_accept(var/mob/living/M)
	if(!..())	return 0

	if(!M.mind || M.mind == target)	return 0 // why protect yourself

	// taking protect and kill contracts for the same guy? nope
	for(var/datum/contract/kill/C in M.mind.antagonist.active_contracts)
		if(istype(C) && C.target == target)	return 0

	return 1

/datum/contract/protect/check_completion()
	if(workers.len == 0)	return

	if(target.current.stat & DEAD || issilicon(target.current) || isbrain(target.current))
		end()
	else if(world.time >= (contract_start + time_limit))
		end(1, workers[1])

/datum/contract/protect/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/protect/C in (faction.contracts + faction.completed_contracts))
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/protect/proc/get_target()
	var/datum/mind/list/candidates = list()
	var/datum/mind/list/taken = get_taken_targets()

	for(var/datum/faction/syndicate/S in (faction_controller.factions - faction))
		if(S.name in faction.alliances)	continue // don't interfere with our alliances
		
		for(var/datum/contract/kill/C in S.contracts)
			if(faction.members.len == 1 && (C.target in faction.members))	continue // no protect contracts for yourself as the sole member of a faction
			if(istype(C) && !(C.target in taken) && C.workers.len)
				candidates += C.target
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise
