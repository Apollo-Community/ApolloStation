/datum/objective/cult_summon
	explanation_text = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."

/datum/objective/cult_summon/check_completion()
	if(locate(/obj/machinery/singularity/narsie/large) in machines) return 1
	return 0