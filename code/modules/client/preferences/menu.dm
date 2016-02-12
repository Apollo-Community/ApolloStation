/datum/preferences/proc/ClientMenu( mob/user )
	if( !user || !istype( user ))
		return

	if( IsGuestKey( user.key ))
		return

	var/menu_name = "client_menu"

	. = "<h2>Client Menu</h2><hr>"
	. += "<table border='1' width='320'>"
	if( selected_character )
		selected_character.update_preview_icon()
		user << browse_rsc(selected_character.preview_icon_front, "previewicon.png")
		user << browse_rsc(selected_character.preview_icon_side, "previewicon2.png")
		. += "<tr>"
		. += "<td><b>Selected:</b></td>"
		. += "<td colspan='2'><a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>[selected_character.name]</a></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td><b>Preview:</b></td>"
		. += "<td colspan='2'><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>New Character</a></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=edit_character'>Edit</a></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=delete_character'>Delete</a></td>"
		. += "</tr>"
	else
		. += "<tr>"
		. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Select a Character</a></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>New Character</a></td>"
		. += "</tr>"

	. += "<tr>"
	. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=client_prefs'>Client Preferences</a></td>"
	. += "</tr>"
	. += "</table>"

	. += "<hr><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a>"


	user << browse( ., "window=[menu_name];size=360x300;can_close=0")
	winshow( user, "client_menu", 1)

/datum/preferences/proc/ClientMenuDisable( mob/user )
	winshow( user, "client_menu", 0)

/datum/preferences/proc/ClientMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "select_character" )
			SelectCharacterMenu( user )
			ClientMenuDisable( user )
		if( "edit_character" )
			if( !selected_character )
				selected_character = new( client )
				characters.Add( selected_character )
			ClientMenuDisable( user )
			selected_character.EditCharacterMenu( user )
		if( "delete_character" )
			characters.Remove( selected_character )
			qdel( selected_character )
			selected_character = null
			ClientMenu( user )
		if( "new_character" )
			selected_character = new( client )
			characters.Add( selected_character )
			ClientMenuDisable( user )
			selected_character.EditCharacterMenu( user )
		if( "client_prefs" )
			ClientMenuDisable( user )
			PreferencesMenu( user )
		if( "close" )
			ClientMenuDisable( user )

/datum/preferences/proc/PreferencesMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "pref_menu"

	. = "<h3>Client Preference Menu</h3><hr>"
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
	. += "<br><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a><br>"

	user << browse( ., "window=[menu_name];size=350x300;can_close=0" )
	winshow( user, "[menu_name]", 1)

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

		if( "close" )
			ClientMenu( user )
			winshow( user, "pref_menu", 0)
			return

	savePreferences()
	PreferencesMenu( user )

/datum/preferences/proc/SelectCharacterMenu( mob/user )
	if( !user || !istype( user ) || !user.client)
		return

	var/menu_name = "select_character_menu"

	. = ""
	. += "<h3>Character Selection Menu</h3><hr>"

	var/sql_ckey = ckey( user.client.ckey )

	var/DBQuery/query = dbcon.NewQuery("SELECT name FROM characters WHERE ckey = '[sql_ckey]'")
	query.Execute()

	while( query.NextRow() )
		if( selected_character && selected_character.name == query.item[1] )
			. += "<b>[query.item[1]]</b> - Selected<br>"
		else
			. += "<a href='byond://?src=\ref[user];preference=[menu_name];task=choose;name=[query.item[1]]'>[query.item[1]]</a><br>"

	. += "<br><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a><br>"

	user << browse( ., "window=[menu_name];size=350x300;can_close=0" )
	winshow( user, "[menu_name]", 1)

/datum/preferences/proc/SelectCharacterMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "choose" )
			var/chosen_name = href_list["name"]
			for( var/datum/character/C in characters)
				if( C.name == chosen_name )
					selected_character = C
					SelectCharacterMenu( user )
					winshow( user, "select_character_menu", 0)
					ClientMenu( user )
					return

			selected_character = new( client )
			characters.Add( selected_character )
			if( !selected_character.loadCharacter( chosen_name ))
				qdel( selected_character )

			winshow( user, "select_character_menu", 0)
			ClientMenu( user )
		if( "close" )
			winshow( user, "select_character_menu", 0)
			ClientMenu( user )
			return

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