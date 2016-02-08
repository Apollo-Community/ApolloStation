/datum/character/proc/FlavorTextMenu(mob/user)
	var/menu_name = "flavor_text_menu"

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];character=[menu_name];task=human'>Humanoid</a>: "
	HTML += TextPreview(flavor_texts_human)
	HTML += "<br>"
	HTML += "<a href ='byond://?src=\ref[user];character=[menu_name];task=robot'>Cyborg</a>: "
	HTML += TextPreview(flavor_texts_robot)
	HTML += "<hr />"
	HTML +="<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"
	HTML += "<tt>"

	user << browse(HTML, "window=[menu_name];size=430x300;titlebar=0")
	winshow( user, "[menu_name]", 1)
	return

/datum/character/proc/FlavorTextMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "close" )
			winshow( user, "flavor_text_menu", 0)
			EditCharacterMenu( user )
			return
		if( "human" )
			var/msg = sanitize(input(usr,"Give a general description of your character. This will be shown regardless of clothing, and may NOT include OOC notes and preferences.","Flavor Text",html_decode(flavor_texts_human)) as message, extra = 0)
			flavor_texts_human = msg
			FlavorTextMenu(user)
		if( "robot" )
			var/msg = sanitize(input(usr,"Give a general description for when you're a cyborg. It will be used for any module without individual setting. It may NOT include OOC notes and preferences.","Flavour Text",html_decode(flavor_texts_robot)) as message, extra = 0)
			flavor_texts_robot = msg
			FlavorTextMenu(user)
