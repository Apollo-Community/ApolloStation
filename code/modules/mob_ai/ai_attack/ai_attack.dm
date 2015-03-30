/datum/ai/proc/check_target()
	if(has_attack_target())
		return 1

	if(find_target())

	return 0

/datum/ai/proc/has_attack_target()
	if(attack_target)
		return 1
	return 0

/datum/ai/proc/find_target()

	return 0

/datum/ai/proc/find_melee_target()
	for(var/mob/M in orange(melee_range))
		if(!(M in friendly_mob_types))

	return 0

/datum/ai/proc/find_ranged_target()

	return 0