// Regular kill contract
/datum/contract/kill
	title = "Kill the Target"
	desc = "We're looking to send a message. A rather strong one."
	time_limit = 2700
	reward = 3000
	
	var/datum/mind/target = null

/datum/contract/kill/New()
	..()
	// Just let the faction controller see if it's a notoriety-restricted contract
	if(ticker.current_state == 1)	return 0

	target = get_target()
	if(!target)
		qdel(src)
		return 0

	set_details()

/datum/contract/kill/set_details()
	title = "[pick(list("Kill", "Murder", "Eliminate"))] [target.current.real_name]"
	desc = "[target.current.real_name], the [target.assigned_role] [pick(list("would serve us better dead", "has been causing us trouble recently", "has badmouthed the wrong people"))]. [pick(list("Kill them at your earliest convenience", "Ensure that they don't live another day", "Eliminate them"))]."
	informal_name = "Kill [target.current.real_name], the [target.assigned_role]"

/datum/contract/kill/can_accept(var/mob/living/M)
	..()

	if(!M.mind || M.mind == target)	return 0 // no suicide missions
	return 1

/datum/contract/kill/check_completion()
	if(workers.len == 0)	return

	if(target.current.stat & DEAD || issilicon(target.current) || isbrain(target.current))
		if(target.current.lastattacker in workers)
			end(1, target.current.lastattacker)
			return
		// Fail! Someone or something hasn't taken the contract, and got them killed (probably themselves).
		end()
	else
		return

/datum/contract/kill/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/kill/C in (faction.contracts + faction.completed_contracts))
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/kill/proc/get_target()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in (ticker.minds - get_taken_targets()))
		if(M in faction.members || (M.antagonist && (M.antagonist.faction.name in faction.alliances)))	continue // no killing coworkers or allies
		if(ishuman(M.current) && M.current.stat != 2)
			candidates += M
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

// Heads only
/datum/contract/kill/head
	title = "Assassinate Head of Staff"
	desc = "We're looking to instate one of our own agents in a position higher up. That means someone already there has to go."
	time_limit = 1200
	min_notoriety = 2

	reward = 4500

/datum/contract/kill/head/get_target()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in (ticker.minds - get_taken_targets()))
		if(ishuman(M.current) && M.current.stat != 2 && M.assigned_role in command_positions)
			candidates += M
	target = (candidates.len > 0 ? pick(candidates) : null)