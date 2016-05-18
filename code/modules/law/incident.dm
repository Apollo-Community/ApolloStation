/datum/crime_incident
	var/UID // The unique identifier for this incident

	var/list/charges = list() // What laws were broken in this incident

	var/list/arbiters = list() // The person or list of people who convicted the criminal
	var/mob/living/carbon/human/criminal // The person who committed the crimes

	var/brig_sentence = 0 // How long do they stay in the brig on the station, PERMABRIG_SENTENCE minutes = permabrig
	var/prison_sentence = 0 // How long do they stay in prison, PERMAPRISON_SENTENCE days = life sentence

	var/fine // how much space dosh do they need to cough up if they want to go free

/datum/crime_incident/New()
	UID = md5( "[world.realtime][rand(0, 1000000)]" )
	..()

/datum/crime_incident/proc/getMinFine()
	var/min = 0
	for( var/datum/law/L in charges )
		min += L.min_fine

	if( min < 0 )
		min = 0

	return min

/datum/crime_incident/proc/getMaxFine()
	var/max = 0
	for( var/datum/law/L in charges )
		max += L.max_fine

	if( max < 0 )
		max = 0

	return max

/datum/crime_incident/proc/getMinBrigSentence()
	var/min = 0
	for( var/datum/law/L in charges )
		min += L.min_brig_time

	if( min < 0 )
		min = 0

	if( min > PERMABRIG_SENTENCE )
		min = PERMABRIG_SENTENCE

	return min

/datum/crime_incident/proc/getMaxBrigSentence()
	var/max = 0
	for( var/datum/law/L in charges )
		max += L.max_brig_time

	if( max < 0 )
		max = 0

	if( max > PERMABRIG_SENTENCE )
		max = PERMABRIG_SENTENCE

	return max

/datum/crime_incident/proc/getMinPrisonSentence()
	var/min = 0
	for( var/datum/law/L in charges )
		min += L.min_prison_time

	if( min < 0 )
		min = 0

	if( min > PERMAPRISON_SENTENCE )
		min = PERMAPRISON_SENTENCE

	return min

/datum/crime_incident/proc/getMaxPrisonSentence()
	var/max = 0
	for( var/datum/law/L in charges )
		max += L.max_prison_time

	if( max < 0 )
		max = 0

	if( max > PERMAPRISON_SENTENCE )
		max = PERMAPRISON_SENTENCE

	return max

/datum/crime_incident/proc/getMaxSeverity()
	var/max = 0
	for( var/datum/law/L in charges )
		if( L.severity > max )
			max = L.severity

	return max

/datum/crime_incident/proc/generateReport()
	return "[criminal] was bad. He's going away for [prison_sentence] days."
