/datum/character/proc/DisabilitiesMenu(mob/user)
	var/menu_name = "disabilities_menu"

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<h3>Disabilities</h3><hr>"

	HTML += "Need Glasses? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=0\">[disabilities & (1<<0) ? "Yes" : "No"]</a><br>"
	HTML += "Seizures? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=1\">[disabilities & (1<<1) ? "Yes" : "No"]</a><br>"
	HTML += "Coughing? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=2\">[disabilities & (1<<2) ? "Yes" : "No"]</a><br>"
	HTML += "Tourettes/Twitching? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=3\">[disabilities & (1<<3) ? "Yes" : "No"]</a><br>"
	HTML += "Nervousness? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=4\">[disabilities & (1<<4) ? "Yes" : "No"]</a><br>"
	HTML += "Deafness? <a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=5\">[disabilities & (1<<5) ? "Yes" : "No"]</a><br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[src];character=[menu_name];disabilities=-1\">Done</a>"
	HTML += "</center></tt>"

	menu.set_user( user )
	menu.set_content( . )
	menu.open()

/datum/character/proc/DisabilitiesMenuProcess( mob/user, list/href_list )
	var/dissab_toggle = text2num(href_list["disabilities"])

	if( dissab_toggle == -1 )
		user << browse(null, "window=disabilities_menu")

	var/dissab_flag = 1<<dissab_toggle

	disabilities ^= dissab_flag
