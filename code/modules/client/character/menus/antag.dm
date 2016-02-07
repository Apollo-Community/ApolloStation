/datum/character/proc/AntagOptionsMenu(mob/user)
	var/menu_name = "antag_options_menu"

	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Antagonist Options</b> <hr />"
	HTML += "<br>"
	HTML +="Uplink Type : <b><a href='byond://?src=\ref[user];character=[menu_name];task=uplinktype;active=1'>[uplinklocation]</a></b>"
	HTML +="<br>"

	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML +="<b><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'>Exploitable information</a></b>:"
		HTML +="[TextPreview(exploit_record,40)]"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='byond://?src=\ref[user];character=[menu_name];task=done'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(HTML, "window=[menu_name]")
	return

/datum/character/proc/AntagOptionsMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "exploitable_record" )
			var/expmsg = sanitize(input(usr,"Set your exploitable information here. This information is used by antags.","Exploitable Information",html_decode(exploit_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if(expmsg != null)
				exploit_record = expmsg
				AntagOptionsMenu(user)
		if( "uplinktype" )
			if (uplinklocation == "PDA")
				uplinklocation = "Headset"
			else if(uplinklocation == "Headset")
				uplinklocation = "None"
			else
				uplinklocation = "PDA"
			AntagOptionsMenu(user)
		if( "done" )
			user << browse(null, "window=antagoptions")
			EditCharacterMenu(user)
