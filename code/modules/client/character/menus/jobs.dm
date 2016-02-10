/datum/character/proc/JobChoicesMenu(mob/user, limit = 16, list/splitJobs = list("Chief Medical Officer"), width = 550, height = 660)
	var/menu_name = "job_choices_menu"

	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.

	var/datum/department/chosen_department = job_master.GetDepartment( department )
	if( !chosen_department )
		ResetJobs()
		chosen_department = job_master.GetDepartment( department )

	var/HTML = "<body>"
	HTML += "<tt><center>"
	if( !chosen_department.department_id )
		HTML += "<b>Branch: </b><a href='byond://?src=\ref[user];character=[menu_name];task=change_branch'>\[[chosen_department.name]\]</a><br><br>"
	else
		HTML += "<b>Branch: </b>[chosen_department.name]<br><br>"
	HTML += "<center><a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)		return
	for( var/role in roles)
		var/datum/job/job = job_master.GetJob(role)
		if( !job )
			continue

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"

		lastJob = job
		if(jobban_isbanned(user, role))
			HTML += "<del>[role]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[role]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if((role in command_positions) || (role == "AI"))//Bold head jobs
			HTML += "<b>[role]</b>"
		else
			HTML += "[role]"

		HTML += "</td><td width='40%'>"

		HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=input;text=[role]'>"
/*
		if(role == "Assistant")//Assistant is special
			if( GetJobLevel( "Assistant" ) != "None" )
				HTML += " <font color=green>\[Yes]</font>"
			else
				HTML += " <font color=red>\[No]</font>"
			if(job.alt_titles) //Blatantly cloned from a few lines down.
				HTML += {"</a></td></tr><tr bgcolor='[lastJob.selection_color]'>
<td width='60%' align='center'><a>&nbsp</a></td>
<td><a href='byond://?src=\ref[user];character=[menu_name];task=alt_title;job=\ref[job]'>\[[GetPlayerAltTitle(job)]\]</a></td></tr>"}
			HTML += "</a></td></tr>"
			continue
*/
		if( GetJobLevel( role ) == "High" )
			HTML += " <font color=blue>\[High]</font>"
		else if( GetJobLevel( role ) == "Medium" )
			HTML += " <font color=green>\[Medium]</font>"
		else if( GetJobLevel( role ) == "Low" )
			HTML += " <font color=orange>\[Low]</font>"
		else
			HTML += " <font color=red>\[NEVER]</font>"
		if(job.alt_titles)
			HTML += {"</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td>
<td><a href='byond://?src=\ref[user];character=[menu_name];task=alt_title;job=\ref[job]'>\[[GetPlayerAltTitle(job)]\]</a></td></tr>"}
		HTML += "</a></td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=green>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=red>Be assistant if preference unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=purple>Return to lobby if preference unavailable</font></a></u></center><br>"

	HTML += "<center>"
	HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=reset'>\[Reset\]</a>"
	HTML += "</center>"
	HTML += "</tt>"

	user << browse(HTML, "window=[menu_name];size=[width]x[height];titlebar=0")
	winshow( user, "[menu_name]", 1)
	return

/datum/character/proc/JobChoicesMenuProcess( mob/user, list/href_list )
	switch(href_list["task"])
		if("close")
			winshow( user, "job_choices_menu", 0)
			EditCharacterMenu(user)
			return
		if("reset")
			ResetJobs()
		if("change_branch")
			var/list/choices = list()
			for( var/datum/department/D in job_master.departments )
				choices[D.name] = D.department_id

			var/choice = input("Select your desire department.", "Branch Selection", null) in choices
			if( choice )
				department = choices[choice]
		if("random")
			if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
				alternate_option += 1
			else if(alternate_option == RETURN_TO_LOBBY)
				alternate_option = 0
			else
				return 0
		if ("alt_title")
			var/datum/job/job = locate(href_list["job"])
			if (job)
				var/choices = list(job.title) + job.alt_titles
				var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
				if(choice)
					SetPlayerAltTitle(job, choice)
		if("input")
			SetJob(user, href_list["text"])

	JobChoicesMenu( user )
