/datum/ai // the AI type
	var/mob/mob = null // The owner of this AI

	var/attack_target = null // The target used for attacks
	var/melee_range = 1 // Range for melee attacks
	var/ranged_range = 7 // Range for ranged attacks

	var/list/friendly_mob_types = null // Mobs that this mob is friendly to, null to be friendly to all mobs


/datum/ai/proc/ai_process() // The main process for mob AI
	if ai_attack()
		return
	else if ai_move()
		return

/datum/ai/proc/ai_attack()
	check_target()


/datum/ai/proc/ai_move()


