/datum/character/proc/AntagOptionsMenu(mob/user)
	var/menu_name = "antag_options_menu"

	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Antagonist Options</b> <hr />"
	HTML += "<br>"
	HTML +="Uplink Type : <b><a href='byond://?src=\ref[user];character=[menu_name];antagtask=uplinktype;active=1'>[uplinklocation]</a></b>"
	HTML +="<br>"
	HTML +="Exploitable information about you : "
	HTML += "<br>"
	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML +="<b><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'>[TextPreview(exploit_record,40)]</a></b>"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='byond://?src=\ref[user];character=[menu_name];antagtask=done;active=1'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(HTML, "window=[menu_name]")
	return

/datum/character/proc/AntagOptionsMenuProcess( mob/user, list/href_list )
	if(text2num(href_list["active"]) == 0)
		AntagOptionsMenu(user)
		return
	if (href_list["antagtask"] == "uplinktype")
		if (uplinklocation == "PDA")
			uplinklocation = "Headset"
		else if(uplinklocation == "Headset")
			uplinklocation = "None"
		else
			uplinklocation = "PDA"
		AntagOptionsMenu(user)
	if (href_list["antagtask"] == "done")
		user << browse(null, "window=antagoptions")
		EditCharacterMenu(user)