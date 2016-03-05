// Regular kill contract
/datum/contract/kill
	title = "Kill the Target"
	desc = "We're looking to send a message. A rather strong one."
	time_limit = 2700
	reward = 3000
	
	var/datum/mind/target = null

/datum/contract/kill/New()
	..()

	target = get_target()
	if(!target)
		// Let the uplink see if it's a notoriety-restricted contract before we delete ourselves
		if(ticker.current_state != 1)
			qdel(src)
		return

	set_details()

/datum/contract/kill/set_details()
	title = "[pick(list("Kill", "Murder", "Eliminate"))] [target.current.real_name]"
	desc = "[target.current.real_name], the [target.assigned_role] [pick(list("would serve us better dead", "has been causing us trouble recently", "has badmouthed the wrong people"))]. [pick(list("Kill them at your earliest convenience", "Ensure that they don't live another day", "Eliminate them"))]."

/datum/contract/kill/check_completion()
	if(target.current.stat & DEAD || issilicon(target.current) || isbrain(target.current))
		if(target.current.lastattacker in workers)
			end(1, target.current.lastattacker)
			return
		// Fail! Someone or something hasn't taken the contract, and got them killed (probably themselves).
		end(0)
	else
		return

/datum/contract/kill/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/kill/C in uplink.contracts)
		if(istype(C) && C.target)	taken += C.target
	return taken

/datum/contract/kill/proc/get_target()
	var/datum/mind/list/taken = get_taken_targets()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in ticker.minds)
		if(!(M in taken) && ishuman(M.current) && M.current.stat != 2)
			candidates += M
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

// Heads only
/datum/contract/kill/head
	title = "Assassinate Head of Staff"
	desc = "We're looking to instate one of our own agents in a position higher up. That means someone already there has to go."
	time_limit = 1200
	min_notoriety = 2

	reward = 6000

/datum/contract/kill/head/get_target()
	var/datum/mind/list/taken = get_taken_targets()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in ticker.minds)
		if(!(M in taken) && ishuman(M.current) && M.current.stat != 2 && M.assigned_role in command_positions)
			candidates += M
	target = (candidates.len > 0 ? pick(candidates) : null)