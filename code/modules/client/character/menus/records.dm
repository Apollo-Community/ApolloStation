/datum/character/proc/RecordsMenu(mob/user)
	var/menu_name = "records_menu"
	var/datum/species/S = all_species[species]

	. = "<html><body><center>"

	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=edit_character_menu'>Appearence</a></b>"
	. += " - "
	. += "<b>Records</b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=job_menu'>Occupation</a></b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=antag_options_menu'>Antag Options</a></b>"
	. += "<hr>"

	. += "<table width='100%'>"
	. += "<tr><td colspan='2' valign='top'>"

	//. += "<table border='1' width='100%'><tr><td valign='top'>"

	. += "<table width='100%' border='1'>"
	. += "<col width='160'>"
	. += "<tr>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=med_record'><b>Medical Records</b></a></td>"
	. += "<td>[TextPreview(med_record,40)]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=gen_record'><b>Employment Records</b></a></td>"
	. += "<td>[TextPreview(gen_record,40)]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=sec_record'><b>Security Records</b></a></td>"
	. += "<td>[TextPreview(sec_record,40)]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'><b>Exploitable Information</b></a></td>"
	. += "<td>[TextPreview(exploit_record,40)]</td>"
	. += "</tr>"

	. += "</table>"

	. += "</td></tr>"
	. += "<tr><td valign='top'>"

	. += "<table width='100%' border='1'>"
	. += "<col width='160'>"
	. += "<tr>"
	. += "<td><b>Home system:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=home_system'>[home_system]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Citizenship:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=citizenship'>[citizenship]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Faction:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=faction'>[faction]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Nanotrasen Relation:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=nt_relation'>[nanotrasen_relation]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Religion:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=religion'>[religion]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Secondary Language:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=language'>[additional_language]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td colspan='2'><center><a href='byond://?src=\ref[user];character=[menu_name];task=pAI'><b>pAI Configuration</b></a></center></td>"
	. += "</tr>"

	. += "</table>"

	. += "</td><td valign='top'>"

	. += "<table width='100%' border='1'>"
	. += "<col width='140'>"
	if( !( S.flags & NO_BLOOD ))
		. += "<tr>"
		. += "<td><b>Blood Type:</b></td>"
		. += "<td>[blood_type]</td>"
		. += "</tr>"

	. += "<tr>"
	. += "<td><b>DNA:</b></td>"
	. += "<td>[DNA]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Fingerprint:</b></td>"
	. += "<td>[fingerprints]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Birth Date:</b></td>"
	. += "<td>[print_birthdate()]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Needs Glasses:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=disabilities'>[disabilities == 0 ? "No" : "Yes"]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Spawn Point:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=spawnpoint'>[spawnpoint]</a></td>"
	. += "</tr>"

	. += "</table>"

	. += "</td></tr>"
	. += "</table>"

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

/datum/character/proc/RecordsMenuDisable( mob/user )
	winshow( user, "records_menu", 0)

/datum/character/proc/RecordsMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "save" )
			if( !saveCharacter( 1 ))
				alert( user, "Character could not be saved to the database, please contact an admin." )

		if( "reset" )
			if( !loadCharacter( name ))
				alert( user, "No savepoint to reset from. You need to save your character first before you can reset." )

		if( "close" )
			RecordsMenuDisable( user )
			user.client.prefs.ClientMenu( user )
			return

		if( "med_record" )
			var/medmsg = sanitize(input(usr,"Set your medical notes here. This information is used by medical staff.","Medical Records",html_decode(med_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(medmsg != null)
				med_record = medmsg

		if( "sec_record" )
			var/secmsg = sanitize(input(usr,"Set your security notes here. This information is used by security staff.","Security Records",html_decode(sec_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(secmsg != null)
				sec_record = secmsg

		if( "gen_record" )
			var/genmsg = sanitize(input(usr,"Set your employment notes here. This information is used by command staff.","Employment Records",html_decode(gen_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(genmsg != null)
				gen_record = genmsg

		if( "exploitable_record" )
			var/exploitmsg = sanitize(input(usr,"Set your exploitable information here. This information is used by antags.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(exploitmsg != null)
				exploit_record = exploitmsg

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

			additional_language = input("Please select a secondary language", "Character Generation", null) in new_languages

		if("nt_relation")
			var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
			if(new_relation)
				nanotrasen_relation = new_relation

		if("spawnpoint")
			var/list/spawnkeys = list()
			for(var/S in spawntypes)
				spawnkeys += S
			var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
			if(!choice || !spawntypes[choice])
				choice = "Arrivals Shuttle"
			spawnpoint = choice

		if("home_system")
			var/choice = input(user, "Please choose a home system.") as null|anything in home_system_choices + list("Unset","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a home system.")  as text|null
				if(raw_choice)
					choice = sanitize(raw_choice)
			home_system = choice

		if("citizenship")
			var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter your current citizenship.", "Character Preference") as text|null
				if(raw_choice)
					choice = sanitize(raw_choice)
			citizenship = choice

		if("faction")
			var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a faction.")  as text|null
				if(raw_choice)
					choice = sanitize(raw_choice)
			faction = choice

		if("religion")
			var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a religon.")  as text|null
				if(raw_choice)
					choice = sanitize(raw_choice)
			religion = choice

		if( "pAI" )
			paiController.recruitWindow(user, 0)
			return 1

	RecordsMenu( user )
