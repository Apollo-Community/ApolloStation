/datum/contract/poison
	title = "Poison the Target"
	desc = "tummy aches :("
	time_limit = 2700
	max_contracts = 1
	reward = 2500
	
	var/datum/mind/target = null

/datum/contract/poison/New()
	. = ..()
	if(!.)	return

	target = get_target()
	if(!target)
		qdel(src)
		return 0

	if(target.assigned_role in command_positions)
		reward = 4000

	set_details()

/datum/contract/poison/start(var/mob/living/worker)
	..()

	var/obj/item/weapon/reagent_containers/glass/bottle/dicardine/P = new(get_turf(worker))

	var/obj/item/weapon/storage/backpack/backpack = locate(/obj/item/weapon/storage/backpack) in worker.contents
	var/can_use_bp = (backpack && backpack.can_be_inserted(P, 1))
	if(can_use_bp)
		backpack.handle_item_insertion(P, 1)
	else
		worker.put_in_any_hand_if_possible(P)

	worker << "The contract author has teleported the gear you will need to complete the contract [can_use_bp ? "to your backpack" : "to your location"]."

/datum/contract/poison/set_details()
	title = "Poison [target.current.real_name]"
	desc = "[target.current.real_name], the [target.assigned_role] [pick(list("is a bit too healthy, go fix that.", "seems to be faring well! That's no fun."))]. Poison them with the potent brew we will teleport to you."
	informal_name = "Poison [target.current.real_name], the [target.assigned_role]"

/datum/contract/poison/can_accept(var/mob/living/M)
	if(!..())	return 0
	
	if(!M.mind || M.mind == target)	return 0 // no suicide missions
	return 1

/datum/contract/poison/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/C in faction.contracts) // targets from these contracts are recycled
		var/datum/contract/poison/P = C
		if((istype(P)) && P.target)	taken += P.target

	return taken

/datum/contract/poison/proc/get_target()
	var/datum/mind/list/candidates = list()
	for(var/datum/mind/M in (ticker.minds - get_taken_targets()))
		if((M.assigned_role == "Gladiator"))	continue // no thunderdome gladiators
		if((M in faction.members) || (M.antagonist && (M.antagonist.faction.name in faction.alliances)))	continue
		
		if(ishuman(M.current) && M.current.stat != 2)
			candidates += M

	return (candidates.len > 0 ? pick(candidates) : null)