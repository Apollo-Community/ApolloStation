/datum/character/proc/AntagOptionsMenu(mob/user)
	var/menu_name = "antag_options_menu"

	if(uplink_location == "" || !uplink_location)
		uplink_location = "PDA"
	. = "<html><body>"
	. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=edit_character_menu'>Appearence</a></b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=records_menu'>Records</a></b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=job_menu'>Occupation</a></b>"
	. += " - "
	. += "<b>Antag Options</b>"
	. += "<hr>"

	. += "Uplink Type : <b><a href='byond://?src=\ref[src];character=[menu_name];task=uplinktype;active=1'>[uplink_location]</a></b>"
	. += "<br>"

	if(jobban_isbanned(user, "Records"))
		. += "<b>You are banned from using character records.</b><br>"
	else
		. += "<br>"
		. +="<b><a href='byond://?src=\ref[src];character=[menu_name];task=exploitable_record'>Exploitable information</a></b><br>"
		. +="[TextPreview(exploit_record,40)]"
	. +="<br>"

	if(jobban_isbanned(user, "Syndicate"))
		. += "<b>You are banned from antagonist roles.</b>"
		src.job_antag = 0
	else
		var/n = 0
		for (var/i in special_roles)
			if(special_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i) || (i == "positronic brain" && jobban_isbanned(user, "AI") && jobban_isbanned(user, "Cyborg")) || (i == "pAI candidate" && jobban_isbanned(user, "pAI")))
					. += "<b>Be [i]:<b> <font color=red><b> BANNED]</b></font><br>"
				else
					. += "<b>Be [i]:</b> <a href='byond://?src=\ref[src];character=[menu_name];task=job_antag;num=[n]'><b>[src.job_antag&(1<<n) ? "Yes" : "No"]</b></a><br>"
			n++

	. += "<hr><center>"
	if(!IsGuestKey(user.key))
		. += "<a href='byond://?src=\ref[src];character=[menu_name];task=save'>Save Setup</a> - "
		. += "<a href='byond://?src=\ref[src];character=[menu_name];task=reset'>Reset Changes</a> - "

	. += "<a href='byond://?src=\ref[src];character=[menu_name];task=close'>Done</a>"
	. += "</center>"
	. += "</body></html>"

	menu.set_user( user )
	menu.set_content( . )
	menu.open()

/datum/character/proc/AntagOptionsMenuDisable( mob/user )
	menu.close()

/datum/character/proc/AntagOptionsMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "save" )
			if( !saveCharacter( 1 ))
				alert( user, "Character could not be saved to the database, please contact an admin." )

		if( "reset" )
			if( !loadCharacter( name ))
				alert( user, "No savepoint to reset from. You need to save your character first before you can reset." )

		if( "close" )
			AntagOptionsMenuDisable( user )

			if( istype( user, /mob/new_player ))
				user.client.prefs.ClientMenu( user )

			return

		if( "exploitable_record" )
			var/expmsg = sanitize(input(usr,"Set your exploitable information here. This information is used by antags.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(expmsg != null)
				exploit_record = expmsg

		if( "uplinktype" )
			if (uplink_location == "PDA")
				uplink_location = "Headset"
			else if(uplink_location == "Headset")
				uplink_location = "None"
			else
				uplink_location = "PDA"

		if("job_antag")
			var/num = text2num(href_list["num"])
			job_antag ^= (1<<num)

	AntagOptionsMenu(user)
