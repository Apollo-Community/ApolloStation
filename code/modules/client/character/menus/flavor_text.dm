/datum/character/proc/FlavorTextMenu(mob/user)
	var/menu_name = "flavor_text_menu"

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=human'>General:</a> "
	HTML += TextPreview(flavor_texts_human["general"])
	HTML += "<br>"
	HTML += "<a href ='byond://?src=\ref[user];character=[menu_name];task=robot'>Default:</a> "
	HTML += TextPreview(flavor_texts_robot["general"])
	HTML += "<hr />"
	HTML +="<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"
	HTML += "<tt>"

	user << browse(HTML, "window=[menu_name];size=430x300")
	return

/datum/character/proc/FlavorTextMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "close" )
			user << browse(null, "window=flavor_text_menu")
			return
		if( "human" )
			var/msg = sanitize(input(usr,"Give a general description of your character. This will be shown regardless of clothing, and may NOT include OOC notes and preferences.","Flavor Text",html_decode(flavor_texts_human[href_list["task"]])) as message, extra = 0)
			flavor_texts_human["general"] = msg
			FlavorTextMenu(user)
		if( "robot" )
			var/msg = sanitize(input(usr,"Set the default flavour text for your robot. It will be used for any module without individual setting.","Flavour Text",html_decode(flavor_texts_robot["Default"])) as message, extra = 0)
			flavor_texts_robot["general"] = msg
			FlavorTextMenu(user)
