
/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == "Assistant")
		if(job_civilian_low & job.flag)
			job_civilian_low &= ~job.flag
		else
			job_civilian_low |= job.flag
		SetChoices(user)
		return 1

	if(GetJobDepartment(job, 1) & job.flag)
		SetJobDepartment(job, 1)
	else if(GetJobDepartment(job, 2) & job.flag)
		SetJobDepartment(job, 2)
	else if(GetJobDepartment(job, 3) & job.flag)
		SetJobDepartment(job, 3)
	else//job = Never
		SetJobDepartment(job, 4)

	SetChoices(user)
	return 1

/datum/preferences/proc/ResetJobs()
	job_civilian_high = 0
	job_civilian_med = 0
	job_civilian_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(1)
					return job_civilian_high
				if(2)
					return job_civilian_med
				if(3)
					return job_civilian_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_civilian_med |= job_civilian_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high
			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0

	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(2)
					job_civilian_high = job.flag
					job_civilian_med &= ~job.flag
				if(3)
					job_civilian_med |= job.flag
					job_civilian_low &= ~job.flag
				else
					job_civilian_low |= job.flag
		if(MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
	return 1