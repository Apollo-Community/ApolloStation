/datum/character/proc/AntagOptionsMenu(mob/user)
	var/menu_name = "antag_options_menu"

	if(uplink_location == "" || !uplink_location)
		uplink_location = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<h3>Antagonist Options</h3><hr>"
	HTML += "<br>"
	HTML += "Uplink Type : <b><a href='byond://?src=\ref[user];character=[menu_name];task=uplinktype;active=1'>[uplink_location]</a></b>"
	HTML += "<br>"

	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML += "<br>"
		HTML +="<b><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'>Exploitable information</a></b><br>"
		HTML +="[TextPreview(exploit_record,40)]"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='byond://?src=\ref[user];character=[menu_name];task=done'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(HTML, "window=[menu_name];titlebar=0")
	return

/datum/character/proc/AntagOptionsMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "exploitable_record" )
			var/expmsg = sanitize(input(usr,"Set your exploitable information here. This information is used by antags.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(expmsg != null)
				exploit_record = expmsg
				AntagOptionsMenu(user)
		if( "uplinktype" )
			if (uplink_location == "PDA")
				uplink_location = "Headset"
			else if(uplink_location == "Headset")
				uplink_location = "None"
			else
				uplink_location = "PDA"
			AntagOptionsMenu(user)
		if( "done" )
			user << browse(null, "window=antagoptions")
			EditCharacterMenu(user)
