// Protect a kill target, essentially an inverse kill contract
/datum/contract/protect
	title = "Protect the Target"
	desc = "We cannot afford for this dude to die until the contract expires."
	time_limit = 2700
	reward = 2000
	
	var/datum/mind/target = null

/datum/contract/protect/New()
	..()
	if(ticker.current_state == 1)	return 0

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

/datum/contract/protect/can_accept(var/mob/living/M)
	..()

	if(!M.mind || M.mind == target)	return 0 // why protect yourself
	if(workers.len > 0)	return 0 // only one person can take this

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
	for(var/datum/contract/protect/C in faction.contracts)
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/protect/proc/get_target()
	var/datum/mind/list/candidates = list()
	var/datum/mind/list/taken = get_taken_targets()
	for(var/datum/contract/kill/C in faction.contracts)
		if(istype(C) && !(C.target in taken))
			candidates += C.target
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise