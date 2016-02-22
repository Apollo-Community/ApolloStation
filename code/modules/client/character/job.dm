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

/datum/character/proc/SelectDepartment( mob/user )
	var/list/choices = list()
	for( var/datum/department/D in job_master.departments )
		choices[D.name] = D

	var/choice = input("Select your desire department.", "Branch Selection", null) in choices
	if( !choice )
		return null

	SetDepartment( choices[choice] )

/datum/character/proc/SetDepartment( var/datum/department/new_department )
	if( !new_department )
		return

	var/datum/department/old_department
	if( department && department.department_id != CIVILIAN ) // If we were in a department that wasn't civilian
		old_department = department

	if( old_department )
		roles -= old_department.getAllPositionNames() // Removing all old departmental roles

	department = new_department
	roles |= new_department.starting_positions

/datum/character/proc/LoadDepartment( var/id )
	if( !job_master )
		return

	var/D = job_master.GetDepartment( id )
	SetDepartment( D )

/datum/character/proc/AddJob( var/job_name )
	for( var/role in roles )
		if( roles[role] == "High" )
			roles[role] = "Medium"

	roles.["[job_name]"] = "High"

/datum/character/proc/RemoveJob( var/job_name )
	roles.Remove( "[job_name]" )

/datum/character/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		EditCharacterMenu(user)
		return

	if(( job.title in roles ) && DepartmentCheck( job ))
		ChangeJobLevel( job.title )
	else if( DepartmentCheck( job ))
		roles[job.title] = "None" // Adding the new roles

	JobChoicesMenu(user)
	return 1

// This checks if the given job is part of our department
/datum/character/proc/DepartmentCheck( var/datum/job/job )
	if( job.department_id == CIVILIAN )
		return 1 // If the job isn't in a department, a la civilian roles

	return department.department_id == job.department_id

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

/datum/character/proc/GetJobLevelNum( var/role )
	if( !( role in roles ))
		return 0

	switch( roles[role] )
		if( "High" )
			return 1
		if( "Medium" )
			return 2
		if( "Low" )
			return 3
		else
			return 0

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
	LoadDepartment( CIVILIAN )

/datum/character/proc/SetJobDepartment( var/datum/job/job )
	department = job.department_id