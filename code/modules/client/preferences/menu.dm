/datum/preferences/proc/ClientMenu( mob/user )
	if( !user || !istype( user ))
		return

	if( IsGuestKey( user.key ))
		return

	var/menu_name = "client_menu"

	. = "<h2>Client Menu</h2><br>"
	if( selected_character )
		selected_character.update_preview_icon()
		user << browse_rsc(selected_character.preview_icon_front, "previewicon.png")
		user << browse_rsc(selected_character.preview_icon_side, "previewicon2.png")
		. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Selected Character: [selected_character.name]</a><br>"
		. += "<b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64>"
		. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=edit_character'>Edit </a>  "
		. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=delete_character'>Delete</a><br>"
	else
		. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Select a Character</a><br>"
	. += "<br>"
	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>Create New Character</a><br>"

	. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=client_prefs'>Client Preferences</a><br>"

	user << browse( ., "window=[menu_name];size=350x300")

/datum/preferences/proc/ClientMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "select_character" )
			SelectCharacterMenu( user )
		if( "edit_character" )
			if( !selected_character )
				selected_character = new()
				characters.Add( selected_character )

			selected_character.EditCharacterMenu( selected_character )
		if( "delete_character" )
			characters.Remove( selected_character )
			qdel( selected_character )
			selected_character = null
		if( "new_character" )
			selected_character = new()
			characters.Add( selected_character )

			selected_character.EditCharacterMenu( selected_character )
		if( "client_prefs" )
			PreferencesMenu( user )

/datum/preferences/proc/PreferencesMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "pref_menu"

	. = "<h2>Client Preference Menu</h2><br>"
	. += "<b>OOC Color:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=OOC_color'>[OOC_color]</a><br><br>"
	. += "<b>UI Style:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=UI_style'>[UI_style]</a><br>"
	. += "<b>UI Transparency:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=UI_trans'>[UI_style_alpha]</a><br>"
	if( UI_style == "White" ) // Only white UI gets custom colors
		. += "<b>UI Color:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=UI_color'>[UI_style_color]</a><br>"
	else
		UI_style_color = initial( UI_style_color )

	. += "<br>"
	. += "<b>Admin Midis:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=hear_midis'>[(toggles & SOUND_MIDI) ? "On" : "Off"]</a><br>"
	. += "<b>Lobby Music:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=lobby_music'>[(toggles & SOUND_LOBBY) ? "On" : "Off"]</a><br>"
	. += "<br>"
	. += "<b>Ghost Ears:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_ears'>[(toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearby Speech"]</a><br>"
	. += "<b>Ghost Sight:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_sight'>[(toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearby Emotes"]</a><br>"
	. += "<b>Ghost Radio:</b> <a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_radio'>[(toggles & CHAT_GHOSTRADIO) ? "All Radio" : "Nearby Radio"]</a><br>"

	user << browse( ., "window=[menu_name];size=350x300" )

/datum/preferences/proc/PreferencesMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "OOC_color" )
			var/new_OOC_color = input(user, "Choose your OOC colour:", "Game Preference") as color|null
			if(new_OOC_color)
				OOC_color = new_OOC_color
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
		if("hear_midis")
			toggles ^= SOUND_MIDI

		if("lobby_music")
			toggles ^= SOUND_LOBBY
			if(toggles & SOUND_LOBBY)
				user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
			else
				user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

		if("ghost_ears")
			toggles ^= CHAT_GHOSTEARS

		if("ghost_sight")
			toggles ^= CHAT_GHOSTSIGHT

		if("ghost_radio")
			toggles ^= CHAT_GHOSTRADIO

	savePreferences()
	PreferencesMenu( user )

/datum/preferences/proc/SelectCharacterMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "select_character_menu"

	. = ""
	. += "<h2>Character Selection Menu</h2><br>"
	for( var/i = 1, i <= characters.len, i++ )
		var/datum/character/character = characters[i]
		if( !character )
			continue

		. += "<a href='byond://?src=\ref[user];preference=[menu_name];number=[i]'>[character.name]</a><br>"

	user << browse( null, "window=[menu_name]" )
	user << browse( ., "window=[menu_name];size=350x300" )

/datum/preferences/proc/SelectCharacterMenuProcess( mob/user, list/href_list )
	var/number = text2num( href_list["number"] )

	if( !number || number < 1 || number > characters.len)
		user << "Could not select character!"
		return

	selected_character = characters[number]

	SelectCharacterMenu( user )

/datum/preferences/proc/process_links( mob/user, list/href_list )
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