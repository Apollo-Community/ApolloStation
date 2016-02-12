/datum/character/proc/RecordsMenu(mob/user)
	var/menu_name = "records_menu"
	var/datum/species/S = all_species[species]

	. = "<html><body><center>"

	. += "<h3>Set Character Records</h3><hr>"

	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=med_record'>Medical Records</a><br>"

	. += TextPreview(med_record,40)

	. += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=gen_record'>Employment Records</a><br>"

	. += TextPreview(gen_record,40)

	. += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=sec_record'>Security Records</a><br>"

	. += TextPreview(sec_record,40)

	. += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'>Exploitable Information</a><br>"

	. += TextPreview(exploit_record,40)

	. += "<br><br>"

	// RECORDS
	. += "<br><br><b>RECORDS</b><br>"
	. += "<b>Home system</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=home_system'>[home_system]</a><br/>"
	. += "<b>Citizenship</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=citizenship'>[citizenship]</a><br/>"
	. += "<b>Faction</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=faction'>[faction]</a><br/>"
	. += "<b>Nanotrasen Relation:</b> <a href='byond://?src=\ref[user];character=[menu_name];task=nt_relation'><b>[nanotrasen_relation]</b></a><br>"
	. += "<b>Religion</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=religion'>[religion]</a><br/>"

	. += "<br><br><b>Occupation Choices</b><br>"
	. += "\t<a href='byond://?src=\ref[user];character=[menu_name];task=job_menu'><b>Set Preferences</b></a><br>"

	. += "<b><a href='byond://?src=\ref[user];character=[menu_name];task=antag_options_menu'>Set Antag Options</b></a><br>"
	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=flavor_text_menu'><b>Set Flavor Text</b></a><br>"

	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=pAI'><b>pAI Configuration</b></a><br>"
	. += "<br>"

	. += "Secondary Language:<br><a href='byond://?src=\ref[user];character=[menu_name];task=language'>[additional_language]</a><br>"

	if( S.flags & NO_BLOOD )
		. += "Blood Type: [blood_type]<br>"

	. += "<b>Spawn Point</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=spawnpoint'>[spawnpoint]</a>"

	. += "<br><br>"

	if(jobban_isbanned(user, "Syndicate"))
		. += "<b>You are banned from antagonist roles.</b>"
		src.job_antag = 0
	else
		var/n = 0
		for (var/i in special_roles)
			if(special_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i) || (i == "positronic brain" && jobban_isbanned(user, "AI") && jobban_isbanned(user, "Cyborg")) || (i == "pAI candidate" && jobban_isbanned(user, "pAI")))
					. += "<b>Be [i]:<b> <font color=red><b> \[BANNED]</b></font><br>"
				else
					. += "<b>Be [i]:</b> <a href='byond://?src=\ref[user];character=[menu_name];task=job_antag;num=[n]'><b>[src.job_antag&(1<<n) ? "Yes" : "No"]</b></a><br>"
			n++
	. += "<hr><center>"

	if(!IsGuestKey(user.key))
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=save'>\[Save Setup\]</a> - "
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=reset'>\[Reset Changes\]</a> - "

	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"

	. += "</center></body></html>"

	user << browse(., "window=[menu_name];size=710x560;can_close=0")
	winshow( user, "[menu_name]", 1)
	return

/datum/character/proc/RecordsMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "close" )
			winshow( user, "records_menu", 0)
			EditCharacterMenu( user )
			return

		if( "med_record" )
			var/medmsg = sanitize(input(usr,"Set your medical notes here. This information is used by medical staff.","Medical Records",html_decode(med_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(medmsg != null)
				med_record = medmsg
				RecordsMenu(user)

		if( "sec_record" )
			var/secmsg = sanitize(input(usr,"Set your security notes here. This information is used by security staff.","Security Records",html_decode(sec_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(secmsg != null)
				sec_record = secmsg
				RecordsMenu(user)

		if( "gen_record" )
			var/genmsg = sanitize(input(usr,"Set your employment notes here. This information is used by command staff.","Employment Records",html_decode(gen_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(genmsg != null)
				gen_record = genmsg
				RecordsMenu(user)

		if( "exploitable_record" )
			var/exploitmsg = sanitize(input(usr,"Set your exploitable information here. This information is used by antags.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(exploitmsg != null)
				exploit_record = exploitmsg
				RecordsMenu(user)
