
/datum/character/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose disabilities</b><br>"

	HTML += "Need Glasses? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=0\">[disabilities & (1<<0) ? "Yes" : "No"]</a><br>"
	HTML += "Seizures? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=1\">[disabilities & (1<<1) ? "Yes" : "No"]</a><br>"
	HTML += "Coughing? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=2\">[disabilities & (1<<2) ? "Yes" : "No"]</a><br>"
	HTML += "Tourettes/Twitching? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=3\">[disabilities & (1<<3) ? "Yes" : "No"]</a><br>"
	HTML += "Nervousness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=4\">[disabilities & (1<<4) ? "Yes" : "No"]</a><br>"
	HTML += "Deafness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=5\">[disabilities & (1<<5) ? "Yes" : "No"]</a><br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preferences=1;disabilities=-2\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/character/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"

	HTML += TextPreview(med_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	HTML += TextPreview(gen_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	HTML += TextPreview(sec_record,40)

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return

/datum/character/proc/SetSpecies(mob/user)
	if(!species_preview || !(species_preview in all_species))
		species_preview = "Human"
	var/datum/species/current_species = all_species[species_preview]
	var/dat = "<body>"
	dat += "<center><h2>[current_species.name] \[<a href='?src=\ref[user];preference=species;task=change'>change</a>\]</h2></center><hr/>"
	dat += "<table padding='8px'>"
	dat += "<tr>"
	dat += "<td width = 400>[current_species.blurb]</td>"
	dat += "<td width = 200 align='center'>"
	if("preview" in icon_states(current_species.icobase))
		usr << browse_rsc(icon(current_species.icobase,"preview"), "species_preview_[current_species.name].png")
		dat += "<img src='species_preview_[current_species.name].png' width='64px' height='64px'><br/><br/>"
	dat += "<b>Language:</b> [current_species.language]<br/>"
	dat += "<small>"
	if(current_species.flags & CAN_JOIN)
		dat += "</br><b>Often present on human stations.</b>"
	if(( current_species.flags & IS_WHITELISTED ) && !( current_species.name in unwhitelisted_aliens ))
		dat += "</br><b>Whitelist restricted.</b>"
	if(current_species.flags & NO_BLOOD)
		dat += "</br><b>Does not have blood.</b>"
	if(current_species.flags & NO_BREATHE)
		dat += "</br><b>Does not breathe.</b>"
	if(current_species.flags & NO_SCAN)
		dat += "</br><b>Does not have DNA.</b>"
	if(current_species.flags & NO_PAIN)
		dat += "</br><b>Does not feel pain.</b>"
	if(current_species.flags & NO_SLIP)
		dat += "</br><b>Has excellent traction.</b>"
	if(current_species.flags & NO_POISON)
		dat += "</br><b>Immune to most poisons.</b>"
	if(current_species.flags & HAS_SKIN_TONE)
		dat += "</br><b>Has a variety of skin tones.</b>"
	if(current_species.flags & HAS_SKIN_COLOR)
		dat += "</br><b>Has a variety of skin colours.</b>"
	if(current_species.flags & HAS_EYE_COLOR)
		dat += "</br><b>Has a variety of eye colours.</b>"
	if(current_species.flags & IS_PLANT)
		dat += "</br><b>Has a plantlike physiology.</b>"
	if(current_species.flags & IS_SYNTHETIC)
		dat += "</br><b>Is machine-based.</b>"
	if(current_species.flags & NO_CRYO)
		dat += "</br><b>Cannot use cryogenics.</b>"
	if(current_species.flags & NO_ROBO_LIMBS)
		dat += "</br><b>Cannot have robotic limbs.</b>"
	dat += "</small></td>"
	dat += "</tr>"
	dat += "</table><center><hr/>"

	if(config.usealienwhitelist )
		if(!is_alien_whitelisted( user, current_species.name ))
			dat += "<font color='red'><b>You cannot play as this species.</br><small>If you wish to be whitelisted, you can make an application post on <a href='?src=\ref[user];preference=open_whitelist_forum'>the forums</a>.</small></b></font></br>"
		else if(!(current_species.flags & CAN_JOIN) && !check_rights(R_ADMIN, 0))
			dat += "<font color='red'><b>You cannot play as this species.</br><small>This species is not available for play as a station race..</small></b></font></br>"
		else
			dat += "\[<a href='?src=\ref[user];preference=species;task=input;newspecies=[species_preview]'>select</a>\]"
	dat += "</center></body>"

	user << browse(null, "window=preferences")
	user << browse(dat, "window=species;size=700x400")

/datum/character/proc/SetFlavorText(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=flavor_text;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=flavor_text;size=430x300")
	return

/datum/character/proc/SetFlavourTextRobot(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Robot Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href ='byond://?src=\ref[user];preference=flavour_text_robot;task=general'>Default:</a> "
	HTML += TextPreview(flavour_texts_robot["general"])
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=flavour_text_robot;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=flavour_text_robot;size=430x300")
	return

/datum/character/proc/SetChoices(mob/user, limit = 16, list/splitJobs = list("Chief Medical Officer"), width = 550, height = 660)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
	HTML += "<center><a href='byond://?src=\ref[user];preference=job;task=close'>\[Done\]</a></center><br>" // Easier to press up here.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)		return
	for(var/datum/job/job in job_master.occupations)

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
		var/rank = job.title
		lastJob = job
		if(jobban_isbanned(user, rank))
			HTML += "<del>[rank]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<del>[rank]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			HTML += "<b>[rank]</b>"
		else
			HTML += "[rank]"

		HTML += "</td><td width='40%'>"

		HTML += "<a href='byond://?src=\ref[user];preference=job;task=input;text=[rank]'>"

		if(rank == "Assistant")//Assistant is special
			if(job_civilian_low & ASSISTANT)
				HTML += " <font color=green>\[Yes]</font>"
			else
				HTML += " <font color=red>\[No]</font>"
			if(job.alt_titles) //Blatantly cloned from a few lines down.
				HTML += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
			HTML += "</a></td></tr>"
			continue

		if(GetJobDepartment(job, 1) & job.flag)
			HTML += " <font color=blue>\[High]</font>"
		else if(GetJobDepartment(job, 2) & job.flag)
			HTML += " <font color=green>\[Medium]</font>"
		else if(GetJobDepartment(job, 3) & job.flag)
			HTML += " <font color=orange>\[Low]</font>"
		else
			HTML += " <font color=red>\[NEVER]</font>"
		if(job.alt_titles)
			HTML += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
		HTML += "</a></td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];preference=job;task=random'><font color=green>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];preference=job;task=random'><font color=red>Be assistant if preference unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><u><a href='byond://?src=\ref[user];preference=job;task=random'><font color=purple>Return to lobby if preference unavailable</font></a></u></center><br>"

	HTML += "<center><a href='byond://?src=\ref[user];preference=job;task=reset'>\[Reset\]</a></center>"
	HTML += "</tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	return

/datum/character/proc/SetAntagoptions(mob/user)
	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Antagonist Options</b> <hr />"
	HTML += "<br>"
	HTML +="Uplink Type : <b><a href='?src=\ref[user];preference=antagoptions;antagtask=uplinktype;active=1'>[uplinklocation]</a></b>"
	HTML +="<br>"
	HTML +="Exploitable information about you : "
	HTML += "<br>"
	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML +="<b><a href=\"byond://?src=\ref[user];preference=records;task=exploitable_record\">[TextPreview(exploit_record,40)]</a></b>"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='?src=\ref[user];preference=antagoptions;antagtask=done;active=1'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=antagoptions")
	return

/datum/character/proc/ShowChoices(mob/user)
	if(!istype( user ) || !user.client)	return

	var/menu_name = "client_menu"

	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")
	var/dat = "<html><body><center>"

	dat += "IMPLEMENT LOADING AND SAVING KWASK"

	dat += "</center><hr><table><tr><td width='340px' height='320px'>"

	dat += "<b>Name:</b> "
	dat += "<a href='byond://?src=\ref[user];preference=name;task=input'><b>[name]</b></a><br>"
	dat += "(<a href='byond://?src=\ref[user];preference=name;task=random'>Random Name</A>) "
	dat += "<br>"

	dat += "<b>Gender:</b> <a href='byond://?src=\ref[user];preference=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
	dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preference=age;task=input'>[age]</a><br>"
	dat += "<b>Spawn Point</b>: <a href='byond://?src=\ref[user];preference=spawnpoint;task=input'>[spawnpoint]</a>"
	dat += "<br>"

	dat += "<br><b>Custom Loadout:</b> "
	var/total_cost = 0

	if(!islist(gear)) gear = list()

	if(gear && gear.len)
		dat += "<br>"
		for(var/i = 1; i <= gear.len; i++)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G)
				if( !G.account )
					total_cost += G.cost
				dat += "[gear[i]]"
				if( !G.account )
					dat += " ([G.cost] points) "
				else
					dat += " (Account Item) "
				dat += "<a href='byond://?src=\ref[user];preference=loadout;task=remove;gear=[i]'>\[remove\]</a><br>"

		dat += "<b>Used:</b> [total_cost] points."
	else
		dat += "none."

	if(total_cost < MAX_GEAR_COST)
		dat += " <a href='byond://?src=\ref[user];preference=loadout;task=input'>\[add\]</a>"
		if(gear && gear.len)
			dat += " <a href='byond://?src=\ref[user];preference=loadout;task=clear'>\[clear\]</a>"
	dat += "<br>"

	dat += "\t<a href='byond://?src=\ref[user];preference=acc_items'><b>Account Items</b></a><br>"

	dat += "<br><br><b>Occupation Choices</b><br>"
	dat += "\t<a href='byond://?src=\ref[user];preference=job;task=menu'><b>Set Preferences</b></a><br>"

	dat += "<br><table><tr><td><b>Body</b> "
	dat += "(<a href='byond://?src=\ref[user];preference=all;task=random'>&reg;</A>)"
	dat += "<br>"
	dat += "Species: <a href='?src=\ref[user];preference=species;task=change'>[species]</a><br>"
	dat += "Secondary Language:<br><a href='byond://?src=\ref[user];preference=language;task=input'>[language]</a><br>"
	dat += "Blood Type: [blood_type]<br>"
	dat += "Skin Tone: <a href='byond://?src=\ref[user];preference=skin_tone;task=input'>[-skin_tone + 35]/220<br></a>"
	dat += "Needs Glasses: <a href='byond://?src=\ref[user];preference=disabilities'><b>[disabilities == 0 ? "No" : "Yes"]</b></a><br>"
	dat += "Limbs: <a href='byond://?src=\ref[user];preference=limbs;task=input'>Adjust</a><br>"
	dat += "Internal Organs: <a href='byond://?src=\ref[user];preference=organs;task=input'>Adjust</a><br>"

	//display limbs below
	var/ind = 0
	for(var/name in organ_data)
		//world << "[ind] \ [organ_data.len]"
		var/status = organ_data[name]
		var/organ_name = null
		switch(name)
			if("l_arm")
				organ_name = "left arm"
			if("r_arm")
				organ_name = "right arm"
			if("l_leg")
				organ_name = "left leg"
			if("r_leg")
				organ_name = "right leg"
			if("l_foot")
				organ_name = "left foot"
			if("r_foot")
				organ_name = "right foot"
			if("l_hand")
				organ_name = "left hand"
			if("r_hand")
				organ_name = "right hand"
			if("heart")
				organ_name = "heart"
			if("eyes")
				organ_name = "eyes"

		if(status == "cyborg")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tMechanical [organ_name] prothesis"
		else if(status == "amputated")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tAmputated [organ_name]"
		else if(status == "mechanical")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tMechanical [organ_name]"
		else if(status == "assisted")
			++ind
			if(ind > 1)
				dat += ", "
			switch(organ_name)
				if("heart")
					dat += "\tPacemaker-assisted [organ_name]"
				if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
					dat += "\tSurgically altered [organ_name]"
				if("eyes")
					dat += "\tRetinal overlayed [organ_name]"
				else
					dat += "\tMechanically assisted [organ_name]"
	if(!ind)
		dat += "\[...\]<br><br>"
	else
		dat += "<br><br>"

	if(gender == MALE)
		dat += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_m[underwear]]</b></a><br>"
	else
		dat += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_f[underwear]]</b></a><br>"

	dat += "Undershirt: <a href='byond://?src=\ref[user];preference=undershirt;task=input'><b>[undershirt_t[undershirt]]</b></a><br>"

	dat += "Backpack Type:<br><a href ='?_src_=prefs;preference=bag;task=input'><b>[backpacklist[backpack]]</b></a><br>"

	dat += "Nanotrasen Relation:<br><a href ='?_src_=prefs;preference=nt_relation;task=input'><b>[nanotrasen_relation]</b></a><br>"

	dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>"

	dat += "</td><td width='300px' height='300px'>"

	if(jobban_isbanned(user, "Records"))
		dat += "<b>You are banned from using character records.</b><br>"
	else
		dat += "<b><a href=\"byond://?src=\ref[user];preference=records;record=1\">Character Records</a></b><br>"

	dat += "<b><a href=\"byond://?src=\ref[user];preference=antagoptions;active=0\">Set Antag Options</b></a><br>"
	dat += "<a href='byond://?src=\ref[user];preference=flavor_text;task=open'><b>Set Flavor Text</b></a><br>"
	dat += "<a href='byond://?src=\ref[user];preference=flavour_text_robot;task=open'><b>Set Robot Flavour Text</b></a><br>"

	dat += "<a href='byond://?src=\ref[user];preference=pAI'><b>pAI Configuration</b></a><br>"
	dat += "<br>"

	dat += "<br><b>Hair</b><br>"
	dat += "<a href='byond://?src=\ref[user];preference=hair;task=input'>Change Color</a> <font face='fixedsys' size='3' color='[hair_color]'><table style='display:inline;' bgcolor='[hair_color]'><tr><td>__</td></tr></table></font> "
	dat += " Style: <a href='byond://?src=\ref[user];preference=hair_style;task=input'>[hair_style]</a><br>"

	dat += "<br><b>Facial</b><br>"
	dat += "<a href='byond://?src=\ref[user];preference=facial;task=input'>Change Color</a> <font face='fixedsys' size='3' color='[hair_face_color]'><table  style='display:inline;' bgcolor='[hair_face_color]'><tr><td>__</td></tr></table></font> "
	dat += " Style: <a href='byond://?src=\ref[user];preference=hair_face_style;task=input'>[hair_face_style]</a><br>"

	dat += "<br><b>Eyes</b><br>"
	dat += "<a href='byond://?src=\ref[user];preference=eyes;task=input'>Change Color</a> <font face='fixedsys' size='3' color='[eye_color]'><table  style='display:inline;' bgcolor='[eye_color]'><tr><td>__</td></tr></table></font><br>"

	dat += "<br><b>Body Color</b><br>"
	dat += "<a href='byond://?src=\ref[user];preference=skin;task=input'>Change Color</a> <font face='fixedsys' size='3' color='[skin_color]'><table style='display:inline;' bgcolor='[skin_color]'><tr><td>__</td></tr></table></font>"

	dat += "<br><br><b>Background Information</b><br>"
	dat += "<b>Home system</b>: <a href='byond://?src=\ref[user];preference=home_system;task=input'>[home_system]</a><br/>"
	dat += "<b>Citizenship</b>: <a href='byond://?src=\ref[user];preference=citizenship;task=input'>[citizenship]</a><br/>"
	dat += "<b>Faction</b>: <a href='byond://?src=\ref[user];preference=faction;task=input'>[faction]</a><br/>"
	dat += "<b>Religion</b>: <a href='byond://?src=\ref[user];preference=religion;task=input'>[religion]</a><br/>"

	dat += "<br><br>"

	if(jobban_isbanned(user, "Syndicate"))
		dat += "<b>You are banned from antagonist roles.</b>"
		src.job_antag = 0
	else
		var/n = 0
		for (var/i in special_roles)
			if(special_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i) || (i == "positronic brain" && jobban_isbanned(user, "AI") && jobban_isbanned(user, "Cyborg")) || (i == "pAI candidate" && jobban_isbanned(user, "pAI")))
					dat += "<b>Be [i]:<b> <font color=red><b> \[BANNED]</b></font><br>"
				else
					dat += "<b>Be [i]:</b> <a href='byond://?src=\ref[user];preference=job_antag;num=[n]'><b>[src.job_antag&(1<<n) ? "Yes" : "No"]</b></a><br>"
			n++
	dat += "</td></tr></table><hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='byond://?src=\ref[user];preference=load'>Undo</a> - "
		dat += "<a href='byond://?src=\ref[user];preference=save'>Save Setup</a> - "

	dat += "<a href='byond://?src=\ref[user];preference=reset_all'>Reset Setup</a>"
	dat += "</center></body></html>"

	user << browse(dat, "window=[menu_name];size=560x736")

/datum/character/proc/process_links(mob/user, list/href_list)
	if(!user)	return

	if(!istype(user, /mob/new_player))	return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forumurl)
			user << link(config.forumurl)
		else
			user << "<span class='danger'>The forum URL is not set in the server configuration.</span>"
			return

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if ("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if (job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"])
			else
				SetChoices(user)
		return 1
/*	else if(href_list["preference"] == "skills")
		if(href_list["cancel"])
			user << browse(null, "window=show_skills")
			ShowChoices(user)
		else if(href_list["skillinfo"])
			var/datum/skill/S = locate(href_list["skillinfo"])
			var/HTML = "<b>[S.name]</b><br>[S.desc]"
			user << browse(HTML, "window=\ref[user]skillinfo")
		else if(href_list["setskill"])
			var/datum/skill/S = locate(href_list["setskill"])
			var/value = text2num(href_list["newvalue"])
			skills[S.ID] = value
			CalculateSkillPoints()
			SetSkills(user)
		else if(href_list["preconfigured"])
			var/selected = input(user, "Select a skillset", "Skillset") as null|anything in SKILL_PRE
			if(!selected) return

			ZeroSkills(1)
			for(var/V in SKILL_PRE[selected])
				if(V == "field")
					skill_specialization = SKILL_PRE[selected]["field"]
					continue
				skills[V] = SKILL_PRE[selected][V]
			CalculateSkillPoints()

			SetSkills(user)
		else if(href_list["setspecialization"])
			skill_specialization = href_list["setspecialization"]
			CalculateSkillPoints()
			SetSkills(user)
		else
			SetSkills(user))
		return 1*/
	else if (href_list["preference"] == "loadout")

		if(href_list["task"] == "input")

			var/list/valid_gear_choices = list()

			for(var/gear_name in gear_datums)
				var/datum/gear/G = gear_datums[gear_name]
				if(G.whitelisted && !is_alien_whitelisted(user, G.whitelisted))
					continue
				if( istype( G, /datum/gear/account ))
					continue
				valid_gear_choices += gear_name

			var/choice = input(user, "Select gear to add: ") as null|anything in valid_gear_choices

			if(choice && gear_datums[choice])

				var/total_cost = 0

				if(isnull(gear) || !islist(gear)) gear = list()

				if(gear && gear.len)
					for(var/gear_name in gear)
						if(gear_datums[gear_name])
							var/datum/gear/G = gear_datums[gear_name]
							total_cost += G.cost

				var/datum/gear/C = gear_datums[choice]
				total_cost += C.cost
				if(C && total_cost <= MAX_GEAR_COST)
					gear += choice
					user << "<span class='notice'>Added \the '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>"
				else
					user << "<span class='warning'>Adding \the '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>"

		else if(href_list["task"] == "remove")
			var/i_remove = text2num(href_list["gear"])
			if(i_remove < 1 || i_remove > gear.len) return
			gear.Cut(i_remove, i_remove + 1)

		else if(href_list["task"] == "clear")
			gear.Cut()
	else if(href_list["preference"] == "acc_items")
		if( !account_items || !account_items.len )
			src << "There are no items tied to your account."
			return

		var/list/valid_gear_choices = list()

		for(var/gear_name in account_items)
			var/datum/gear/G = gear_datums[gear_name]
			if( !G )
				continue
			if( !G.account )
				continue
			valid_gear_choices += gear_name

		var/choice = input(user, "Select item to add: ") as null|anything in valid_gear_choices

		if( !choice )
			return

		if( choice in gear )
			user << "<span class='warning'>You already have this item selected.</span>"
			return

		if( !gear_datums[choice] )
			return

		if(isnull(gear) || !islist(gear))
			gear = list()

		gear += choice
		user << "<span class='notice'>Added \the '[choice]'.</span>"

	else if(href_list["preference"] == "flavor_text")
		switch(href_list["task"])
			if("open")
				SetFlavorText(user)
				return
			if("done")
				user << browse(null, "window=flavor_text")
				ShowChoices(user)
				return
			if("general")
				var/msg = sanitize(input(usr,"Give a general description of your character. This will be shown regardless of clothing, and may include OOC notes and preferences.","Flavor Text",html_decode(flavor_texts[href_list["task"]])) as message, extra = 0)
				flavor_texts[href_list["task"]] = msg
			else
				var/msg = sanitize(input(usr,"Set the flavor text for your [href_list["task"]].","Flavor Text",html_decode(flavor_texts[href_list["task"]])) as message, extra = 0)
				flavor_texts[href_list["task"]] = msg
		SetFlavorText(user)
		return

	else if(href_list["preference"] == "flavour_text_robot")
		switch(href_list["task"])
			if("open")
				SetFlavourTextRobot(user)
				return
			if("done")
				user << browse(null, "window=flavour_text_robot")
				ShowChoices(user)
				return
			if("Default")
				var/msg = sanitize(input(usr,"Set the default flavour text for your robot. It will be used for any module without individual setting.","Flavour Text",html_decode(flavour_texts_robot["Default"])) as message, extra = 0)
				flavour_texts_robot[href_list["task"]] = msg
			else
				var/msg = sanitize(input(usr,"Set the flavour text for your robot with [href_list["task"]] module. If you leave this empty, default flavour text will be used for this module.","Flavour Text",html_decode(flavour_texts_robot[href_list["task"]])) as message, extra = 0)
				flavour_texts_robot[href_list["task"]] = msg
		SetFlavourTextRobot(user)
		return

	else if(href_list["preference"] == "pAI")
		paiController.recruitWindow(user, 0)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = sanitize(input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(medmsg != null)
				med_record = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = sanitize(input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(secmsg != null)
				sec_record = secmsg
				SetRecords(user)
		if(href_list["task"] == "gen_record")
			var/genmsg = sanitize(input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(genmsg != null)
				gen_record = genmsg
				SetRecords(user)

		if(href_list["task"] == "exploitable_record")
			var/exploitmsg = sanitize(input(usr,"Set exploitable information about you here.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(exploitmsg != null)
				exploit_record = exploitmsg
				SetAntagoptions(user)

	else if (href_list["preference"] == "antagoptions")
		if(text2num(href_list["active"]) == 0)
			SetAntagoptions(user)
			return
		if (href_list["antagtask"] == "uplinktype")
			if (uplinklocation == "PDA")
				uplinklocation = "Headset"
			else if(uplinklocation == "Headset")
				uplinklocation = "None"
			else
				uplinklocation = "PDA"
			SetAntagoptions(user)
		if (href_list["antagtask"] == "done")
			user << browse(null, "window=antagoptions")
			ShowChoices(user)
		return 1

	else if (href_list["preference"] == "loadout")

		if(href_list["task"] == "input")

			var/list/valid_gear_choices = list()

			for(var/gear_name in gear_datums)
				var/datum/gear/G = gear_datums[gear_name]

				if(( G.whitelisted && !is_alien_whitelisted( user, G.whitelisted )) || G.account )
					continue
				valid_gear_choices += gear_name

			var/choice = input(user, "Select gear to add: ") as null|anything in valid_gear_choices

			if(choice && gear_datums[choice])

				var/total_cost = 0

				if(isnull(gear) || !islist(gear)) gear = list()

				if(gear && gear.len)
					for(var/gear_name in gear)
						if(gear_datums[gear_name])
							var/datum/gear/G = gear_datums[gear_name]
							total_cost += G.cost

				var/datum/gear/C = gear_datums[choice]
				total_cost += C.cost
				if(C && total_cost <= MAX_GEAR_COST)
					gear += choice
					user << "<span class='notice'>Added [choice] for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>"
				else
					user << "<span class='alert'>That item will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>"

		else if(href_list["task"] == "remove")

			if(isnull(gear) || !islist(gear))
				gear = list()
			if(!gear.len)
				return

			var/choice = input(user, "Select gear to remove: ") as null|anything in gear
			if(!choice)
				return

			for(var/gear_name in gear)
				if(gear_name == choice)
					gear -= gear_name
					break

	switch(href_list["task"])
		if("change")
			if(href_list["preference"] == "species")
				// Actual whitelist checks are handled elsewhere, this is just for accessing the preview window.
				var/choice = input("Which species would you like to look at?") as null|anything in playable_species
				if(!choice) return
				species_preview = choice
				SetSpecies(user)

		if("random")
			switch(href_list["preference"])
				if("name")
					name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair_color")
					hair_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("hair_style")
					hair_style = random_hair_style(gender, species)
				if("facial")
					hair_face_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("hair_face_style")
					hair_face_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = rand(1,underwear_m.len)
					ShowChoices(user)
				if("undershirt")
					undershirt = rand(1,undershirt_t.len)
					ShowChoices(user)
				if("eye_color")
					eye_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("skin_tone")
					skin_tone = random_skin_tone()
				if("skin_color")
					skin_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("bag")
					backpack = rand(1,4)
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = input(user, "Choose your character's name:", "Character Preference")  as text|null
					if (!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = sanitizeName(raw_name)
						if(new_name)
							name = new_name
						else
							user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")
					user << browse(null, "window=species")
					var/prev_species = species
					species = href_list["newspecies"]
					if(prev_species != species)
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if( !(species in S.species_allowed))
								continue
							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						if(valid_hairstyles.len)
							hair_style = pick(valid_hairstyles)
						else
							//this shouldn't happen
							hair_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

						if(valid_facialhairstyles.len)
							hair_face_style = pick(valid_facialhairstyles)
						else
							//this shouldn't happen
							hair_face_style = facial_hair_styles_list["Shaved"]

						//reset hair colour and skin colour
						hair_color = rgb( 0, 0, 0 )

						skin_tone = 0

				if("language")
					var/languages_available
					var/list/new_languages = list("None")
					var/datum/species/S = all_species[species]

					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))||(S && (L in S.secondary_langs))))
								new_languages += lang

								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if(!(lang.flags & RESTRICTED))
								new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("blood_type")
					var/new_blood_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_blood_type)
						blood_type = new_blood_type

				if("hair")
					if(species == "Human" || species == "Unathi" || species == "Tajara" || species == "Skrell" || species == "Wryn")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference", hair_color ) as color|null
						if( new_hair )
							hair_color = new_hair

				if("hair_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if( !(species in S.species_allowed))
							continue

						valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

					var/new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
					if(new_hair_style)
						hair_style = new_hair_style

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", hair_face_color ) as color|null
					if(new_facial)
						hair_face_color = new_facial

				if("hair_face_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if( !(species in S.species_allowed))
							continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_hair_face_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_hair_face_style)
						hair_face_style = new_hair_face_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)
					ShowChoices(user)

				if("undershirt")
					var/list/undershirt_options
					undershirt_options = undershirt_t

					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_options
					if (new_undershirt)
						undershirt = undershirt_options.Find(new_undershirt)
					ShowChoices(user)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", eye_color ) as color|null
					if(new_eyes)
						eye_color = new_eyes

				if("skin_tone")
					if(species != "Human")
						return
					var/new_skin_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
					if(new_skin_tone)
						skin_tone = 35 - max(min( round(new_skin_tone), 220),1)

				if("skin")
					if(species == "Unathi" || species == "Tajara" || species == "Skrell" || species == "Wryn")
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", skin_color ) as color|null
						if(new_skin)
							skin_color = new_skin
/*
				if("OOC_color")
					var/new_OOC_color = input(user, "Choose your OOC colour:", "Game Preference") as color|null
					if(new_OOC_color)
						OOC_color = new_OOC_color
*/
				if("bag")
					var/new_backpack = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backpacklist
					if(new_backpack)
						backpack = backpacklist.Find(new_backpack)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("disabilities")
					if(text2num(href_list["disabilities"]) >= -1)
						if(text2num(href_list["disabilities"]) >= 0)
							disabilities ^= (1<<text2num(href_list["disabilities"])) //MAGIC
						SetDisabilities(user)
						return
					else
						user << browse(null, "window=disabil")

				if("limbs")
					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					switch(limb_name)
						if("Left Leg")
							limb = "l_leg"
							second_limb = "l_foot"
						if("Right Leg")
							limb = "r_leg"
							second_limb = "r_foot"
						if("Left Arm")
							limb = "l_arm"
							second_limb = "l_hand"
						if("Right Arm")
							limb = "r_arm"
							second_limb = "r_hand"
						if("Left Foot")
							limb = "l_foot"
							third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Amputated","Prothesis")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
						if("Amputated")
							organ_data[limb] = "amputated"
							if(second_limb)
								organ_data[second_limb] = "amputated"
						if("Prothesis")
							organ_data[limb] = "cyborg"
							if(second_limb)
								organ_data[second_limb] = "cyborg"
							if(third_limb && organ_data[third_limb] == "amputated")
								organ_data[third_limb] = null
				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
					if(!organ_name) return

					var/organ = null
					switch(organ_name)
						if("Heart")
							organ = "heart"
						if("Eyes")
							organ = "eyes"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Assisted")
							organ_data[organ] = "assisted"
						if("Mechanical")
							organ_data[organ] = "mechanical"

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return

				if("spawnpoint")
					var/list/spawnkeys = list()
					for(var/S in spawntypes)
						spawnkeys += S
					var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
					if(!choice || !spawntypes[choice])
						spawnpoint = "Arrivals Shuttle"
						return
					spawnpoint = choice

				if("home_system")
					var/choice = input(user, "Please choose a home system.") as null|anything in home_system_choices + list("Unset","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a home system.")  as text|null
						if(raw_choice)
							home_system = sanitize(raw_choice)
						return
					home_system = choice
				if("citizenship")
					var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter your current citizenship.", "Character Preference") as text|null
						if(raw_choice)
							citizenship = sanitize(raw_choice)
						return
					citizenship = choice
				if("faction")
					var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a faction.")  as text|null
						if(raw_choice)
							faction = sanitize(raw_choice)
						return
					faction = choice
				if("religion")
					var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a religon.")  as text|null
						if(raw_choice)
							religion = sanitize(raw_choice)
						return
					religion = choice
		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE

				if("disabilities")				//please note: current code only allows nearsightedness as a disability
					disabilities = !disabilities//if you want to add actual disabilities, code that selects them should be here

/*				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Orange"
						if("Orange")
							UI_style = "old"
						if("old")
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

				if("job_antag")
					var/num = text2num(href_list["num"])
					job_antag ^= (1<<num)

				if("name")
					be_random_name = !be_random_name

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
					else
						user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("save")
					savePreferences()
					save_character()

				if("reset")
					load_preferences()
					load_character()

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					load_character(text2num(href_list["num"]))
					close_load_dialog(user)*/

	ShowChoices(user)
	return 1