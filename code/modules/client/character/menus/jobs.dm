/datum/character/proc/JobChoicesMenu(mob/user, limit = 16, list/splitJobs = list("Chief Medical Officer"))
	var/menu_name = "job_choices_menu"

	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.

	if( !department )
		ResetJobs()

	. = "<html><body>"
	. += "<center>"

	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=edit_character_menu'>Appearence</a></b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=records_menu'>Records</a></b>"
	. += " - "
	. += "<b>Occupation</b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=antag_options_menu'>Antag Options</a></b>"
	. += "<hr>"

	if( !department.department_id )
		. += "<b>Branch: </b><a href='byond://?src=\ref[user];character=[menu_name];task=change_branch'>\[[department.name]\]</a><br><br>"
	else
		. += "<b>Branch: </b>[department.name]<br><br>"
	. += "<center><a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	. += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	. += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)		return
	for( var/role in roles)
		var/datum/job/job = job_master.GetJob(role)
		if( !job )
			continue

		var/required_playtime = 0
		if( user.client.total_playtime_hours() <= job.minimal_playtime )
			required_playtime = job.minimal_playtime-user.client.total_playtime_hours()

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					. += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			. += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		. += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"

		lastJob = job
		if(jobban_isbanned(user, role))
			. += "<del>[role]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			. += "<del>[role]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if((role in command_positions) || (role == "AI"))//Bold head jobs
			. += "<b>[role]</b>"
		else
			. += "[role]"

		. += "</td><td width='40%'>"

		if( !required_playtime )
			. += "<a href='byond://?src=\ref[user];character=[menu_name];task=input;text=[role]'>"

		if( required_playtime )
			. += " [required_playtime] hours to unlock"
		else if( GetJobLevel( role ) == "High" )
			. += " <font color=blue>\[High]</font>"
		else if( GetJobLevel( role ) == "Medium" )
			. += " <font color=green>\[Medium]</font>"
		else if( GetJobLevel( role ) == "Low" )
			. += " <font color=orange>\[Low]</font>"
		else
			. += " <font color=red>\[NEVER]</font>"

		if(job.alt_titles && !required_playtime)
			. += {"</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td>
<td><a href='byond://?src=\ref[user];character=[menu_name];task=alt_title;job=\ref[job]'>\[[GetPlayerAltTitle(job)]\]</a></td></tr>"}
		else if( !required_playtime )
			. += "</a>"

		. += "</td></tr>"

	. += "</td'></tr></table>"

	. += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=green>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_ASSISTANT)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=red>Be assistant if preference unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=purple>Return to lobby if preference unavailable</font></a></u></center><br>"

	. += "<hr><center>"
	if(!IsGuestKey(user.key))
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=save'>\[Save Setup\]</a> - "
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=reset'>\[Reset Changes\]</a> - "

	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"
	. += "</center>"
	. += "</body></html>"

	user << browse(., "window=[menu_name];size=710x560;can_close=0")
	winshow( user, "[menu_name]", 1)
	return

/datum/character/proc/JobChoicesMenuDisable( mob/user )
	winshow( user, "job_choices_menu", 0)

/datum/character/proc/JobChoicesMenuProcess( mob/user, list/href_list )
	switch(href_list["task"])
		if( "save" )
			if( !saveCharacter( 1 ))
				alert( user, "Character could not be saved to the database, please contact an admin." )

		if( "reset" )
			if( !loadCharacter( name ))
				alert( user, "No savepoint to reset from. You need to save your character first before you can reset." )

		if("close")
			JobChoicesMenuDisable( user )
			user.client.prefs.ClientMenu( user )
			return

		if("change_branch")
			var/list/choices = list()
			for( var/datum/department/D in job_master.departments )
				choices[D.name] = D

			var/choice = input("Select your desired department.", "Branch Selection", null) in choices
			if( choice )
				SetDepartment( choices[choice] )
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
