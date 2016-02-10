/proc/ShowChainOfCommand()
	for( var/i = 0; i < 20; i++ )
		var/job_found = 0
		for( var/datum/job/job in job_master.occupations )
			if( job.rank_succesion_level == i )
				job_found = 1
				world << "[job.title]"

		if( job_found )
			world << "Succesion level: [i]"

/datum/character/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/character/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/character/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		EditCharacterMenu(user)
		return

	if( job.title in roles && DepartmentCheck( job ) )
		ChangeJobLevel( job.title )
	else if( DepartmentCheck( job ))
		roles[job.title] = "None" // Adding the new roles

	JobChoicesMenu(user)
	return 1

// This checks if the given job is part of our department
/datum/character/proc/DepartmentCheck( var/datum/job/job )
	return department == job.department_id

/datum/character/proc/ChangeJobLevel( var/role )
	if( !( role in roles ))
		return 0

	switch( roles[role] )
		if( "None" )
			roles[role] = "Low"
			return 2
		if( "Low" )
			roles[role] = "Medium"
			return 3
		if( "Medium" )
			roles[role] = "High"
			return 4
		if( "High" )
			roles[role] = "None"
			return 1

/datum/character/proc/GetJobLevel( var/role )
	if( !( role in roles ))
		return 0

	return roles[role]

/datum/character/proc/GetHighestLevelJob()
	var/list/levels = list( "High", "Medium", "Low", "None" )

	for( var/level in levels )
		if( level == "None" )
			switch(alternate_option)
				if(GET_RANDOM_JOB)
					return pick( roles )
				if(BE_ASSISTANT)
					return "Assistant"
				if(RETURN_TO_LOBBY)
					return

		for( var/role in roles )
			if( roles[role] == level )
				return role

/datum/character/proc/ResetJobs()
	department = 0
	roles = list( "Assistant" = "High" )

/datum/character/proc/GetJobDepartment()
	return department

/datum/character/proc/SetJobDepartment( var/datum/job/job )
	department = job.department_id