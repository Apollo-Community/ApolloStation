// Regular kill contract
/datum/contract/kill
	title = "Kill the Target"
	desc = "We're looking to send a message. A rather strong one."
	time_limit = 2700
	min_notoriety = 2
	reward = 3000
	
	var/datum/mind/target = null

/datum/contract/kill/New()
	. = ..()
	if(!.)	return

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
	if(!..())	return 0
	
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
	for(var/datum/contract/C in (faction.contracts + faction.completed_contracts))
		var/datum/contract/kill/K = C
		if((istype(K)) && K.target)	taken += K.target
	return taken

/datum/contract/kill/proc/get_target()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in (ticker.minds - get_taken_targets()))
		if((M.assigned_role == "Gladiator"))	continue // no thunderdome gladiators
		if((M.assigned_role in command_positions))	continue // head contract's stuff
		if((M in faction.members) || (M.antagonist && (M.antagonist.faction.name in faction.alliances)))	continue // no killing coworkers or allies. heads are excluded from normal kill contracts
		if(ishuman(M.current) && M.current.stat != 2)
			candidates += M
	return (candidates.len > 0 ? pick(candidates) : null) // pick(candidates) if candidates isn't empty. null otherwise

// Heads only
/datum/contract/kill/head
	title = "Assassinate Head of Staff"
	desc = "We're looking to instate one of our own agents in a position higher up. That means someone already there has to go."
	time_limit = 2700
	min_notoriety = 4

	reward = 5000

/datum/contract/kill/head/New()
	. = ..()
	if(!.)	return

	target = get_target()
	if(!target)
		qdel(src)
		return 0

	// the hard ones give the big bucks
	if(target.assigned_role == "Captain" || target.assigned_role == "Head of Security")
		reward = 8000

	set_details()

/datum/contract/kill/head/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/C in (faction.contracts + faction.completed_contracts))
		var/datum/contract/kill/head/K = C
		if((istype(K)) && K.target)	taken += K.target
	return taken

/datum/contract/kill/head/get_target()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in (ticker.minds - get_taken_targets()))
		if(ishuman(M.current) && M.current.stat != 2 && M.assigned_role in command_positions)
			candidates += M
	target = (candidates.len > 0 ? pick(candidates) : null)

// Kill someone's pet. You monster
/datum/contract/kill/pet
	title = "Murder some poor guy's pet"
	desc = "be an asshole"
	time_limit = 1800
	min_notoriety = 0

	reward = 1500

	var/mob/living/pet_target = null

/datum/contract/kill/pet/New()
	. = ..()
	if(!.)	return

	pet_target = get_target()
	if(!pet_target)
		qdel(src)
		return 0

	set_details()

/datum/contract/kill/pet/set_details()
	if(istype(faction, /datum/faction/syndicate/arc))
		title = "Euthanize [pet_target.name]"
		desc = "[pet_target.name] is being held in captivity, [pick(list("set the poor soul free!", "free the animal from its miserable life!"))]"
	else
		title = "[pick(list("Kill", "Murder", "Eliminate"))] [pet_target.name]"
		desc = "[pet_target.name] is a dear mascot to their department. [pick(list("Please, murder the animal.", "Just kill them."))]"
	informal_name = "Kill [pet_target.name]"

/datum/contract/kill/pet/check_completion()
	if(workers.len == 0)	return

	if(pet_target.isDead())
		if(pet_target.lastattacker in workers)
			end(1, pet_target.lastattacker)
			return
		end()
	else
		return

/datum/contract/kill/pet/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/C in (faction.contracts + faction.completed_contracts))
		var/datum/contract/kill/pet/K = C
		if((istype(K)) && K.pet_target)	taken += K.pet_target
	return taken

/datum/contract/kill/pet/get_target()
	var/datum/mind/list/candidates = list()
	var/mob/living/simple_animal/list/taken = get_taken_targets()

	var/mob/living/simple_animal/pets = list(
		/mob/living/simple_animal/parrot/Poly,
		/mob/living/simple_animal/dog/labrador/beaker,
		/mob/living/simple_animal/cat/Runtime,
		/mob/living/simple_animal/dog/german_shep/sirius,
		/mob/living/simple_animal/dog/corgi/Ian
	)

	for(var/P in pets)
		var/mob/living/simple_animal/M = locate(P)
		if(M && !M.isDead() && !(M in taken))
			candidates += M
	pet_target = (candidates.len > 0 ? pick(candidates) : null)