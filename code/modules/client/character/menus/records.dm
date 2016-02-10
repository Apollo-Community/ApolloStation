/datum/character/proc/RecordsMenu(mob/user)
	var/menu_name = "records_menu"

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<h3>Set Character Records</h3><hr>"

	HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=med_record'>Medical Records</a><br>"

	HTML += TextPreview(med_record,40)

	HTML += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=gen_record'>Employment Records</a><br>"

	HTML += TextPreview(gen_record,40)

	HTML += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=sec_record'>Security Records</a><br>"

	HTML += TextPreview(sec_record,40)

	HTML += "<br><br><a href='byond://?src=\ref[user];character=[menu_name];task=exploitable_record'>Exploitable Information</a><br>"

	HTML += TextPreview(exploit_record,40)

	HTML += "<br><br>"
	HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(HTML, "window=[menu_name];size=350x300;can_close=0")
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
