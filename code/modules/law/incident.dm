/datum/crime_incident
	var/list/laws = list() // What laws were broken in this incident

	var/list/arbiters = list() // The person or list of people who convicted the criminal
	var/mob/living/carbon/human/criminal // The person who committed the crimes

	var/brig_sentence // How long do they stay in the brig on the station, 60 minutes = permabrig
	var/prison_sentence // How long do they stay in prison, 60 days = life sentence

	var/fine // how much space dosh do they need to cough up if they want to go free

/datum/crime_incident/proc/getMinFine()
	var/min = 0
	for( var/datum/law/L in laws )
		min += L.min_fine

	return min

/datum/crime_incident/proc/getMaxFine()
	var/max = 0
	for( var/datum/law/L in laws )
		max += L.max_fine

	return max

/datum/crime_incident/proc/getMinBrigSentence()
	var/min = 0
	for( var/datum/law/L in laws )
		min += L.min_brig_time

	return min

/datum/crime_incident/proc/getMaxBrigSentence()
	var/max = 0
	for( var/datum/law/L in laws )
		max += L.max_brig_time

	return max

/datum/crime_incident/proc/getMinPrisonSentence()
	var/min = 0
	for( var/datum/law/L in laws )
		min += L.min_prison_time

	return min

/datum/crime_incident/proc/getMaxPrisonSentence()
	var/max = 0
	for( var/datum/law/L in laws )
		max += L.max_prison_time

	return max

/datum/crime_incident/proc/generateReport()
	return "[criminal] was bad. He's going away for [prison_sentence] days."
