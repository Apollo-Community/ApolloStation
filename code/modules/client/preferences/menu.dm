/datum/preferences/proc/ClientMenu( mob/user )
	if( !user || !istype( user ))
		return

	if( IsGuestKey( user.key ))
		return

	var/menu_name = "client_menu"

	. = "Client Menu<br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Select Character</a><br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=edit_character'>Edit Character</a><br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>Create Character</a><br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=delete_character'>Delete Character</a><br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=client_prefs'>Client Preferences</a><br>"

	user << browse(null, "window=[menu_name]")
	user << browse(HTML, "window=[menu_name];size=350x300")

/datum/preferences/proc/ClientMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "select_character" )

		if( "edit_character" )

		if( "new_character" )

		if( "delete_character" )

		if( "client_prefs" )
			PreferencesMenu( user )

/datum/preferences/proc/PreferencesMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "pref_menu"

	. = "Client Preference Menu<br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=OOC_color>OOC Color</a><br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=UI_style>UI Style: [UI_style]</a><br>"

	if( UI_style == "White" ) // Only white UI gets custom colors
		. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=UI_color>UI Color: [UI_style_color]</a><br>"
	else
		UI_style_color = initial( UI_style_color )

	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=UI_trans>UI Transparency: [UI_style_alpha]</a><br>"

	. += "<br>"

	user << browse(null, "window=[menu_name]")
	user << browse(HTML, "window=[menu_name];size=350x300")

/datum/preferences/proc/PreferencesMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "OOC_color" )
			var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
			if(new_ooccolor)
				ooccolor = new_ooccolor
		if( "UI_style" )
			switch(UI_style)
				if("Midnight")
					UI_style = "Orange"
				if("Orange")
					UI_style = "old"
				if("old")
					UI_style = "White"
				else
					UI_style = "Midnight"
		if( "UI_color" )
			var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
			if(!UI_style_color_new)
				return
			UI_style_color = UI_style_color_new
		if( "UI_trans" )
			var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
			if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50))
				return
			UI_style_alpha = UI_style_alpha_new

/datum/preferences/proc/SelectCharacterMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "select_character_menu"

	. = ""
	. += "Character Selection Menu<br>"
	for( var/i = 1, i <= characters.len, i++ )
		var/datum/character/character = characters[i]
		if( !character )
			continue

		. += "<a href='byond://?src=\ref[user];preference=[menu_name];number=[i]>[character.name]</a><br>"

	user << browse(null, "window=[menu_name]")
	user << browse(HTML, "window=[menu_name];size=350x300")

/datum/preferences/proc/SelectCharacterMenuProcess( mob/user, list/href_list )
	var/number = text2num( href_list["number"] )

	if( !number || number > characters.len)
		user << "Could not select character!"
		return

	selected_character = characters[number]

/datum/preferences/proc/process_link( mob/user, list/href_list )
	if( !user )	return

	if( !istype( user, /mob/new_player ))	return

	if( href_list["preference"] == "client_menu" )
		ClientMenuProcess( user, href_list )
		return 1
	else if( href_list["preference"] == "pref_menu" )
		PreferencesMenuProcess( user, href_list )
		return 1
	else if( href_list["preference"] == "select_character_menu" )
		SelectCharacterMenuProcess( user, href_list )
		return 1