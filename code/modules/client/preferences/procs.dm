/datum/preferences/New( client/C )
	if(istype(C))
		client = C
		if(!IsGuestKey(client.key))
			if(loadPreferences())
				return
			if(loadCharacters())
				return

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if( !selected_character )
		return

	return selected_character.GetJobDepartment( job, level )

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	if( !selected_character )
		return

	return selected_character.GetPlayerAltTitle( job )

/datum/preferences/proc/beSpecial()
	if( !selected_character )
		return

	return selected_character.job_antag

/datum/preferences/proc/savePreferences()
	return 0

/datum/preferences/proc/saveCharacter()
	if( !selected_character )
		return

	return selected_character.saveCharacter()

/datum/preferences/proc/loadPreferences()
	return 0

/datum/preferences/proc/loadCharacters()
	return 0
