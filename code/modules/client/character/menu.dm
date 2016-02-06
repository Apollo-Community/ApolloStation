/datum/character/proc/process_links( mob/user, list/href_list )
	if(!user)	return

	if(!istype(user, /mob/new_player))	return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forumurl)
			user << link(config.forumurl)
		else
			user << "<span class='danger'>The forum URL is not set in the server configuration.</span>"
			return

	if(href_list["preference"] == "disabilities_menu" )
		DisabilitiesMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "records_menu" )
		RecordsMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "flavor_text_menu" )
		FlavorTextMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "job_menu")
		JobChoicesMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "antag_options_menu" )
		AntagOptionsMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "edit_character" )
		EditCharacterMenuProcess( user, href_list )
		return 1

	EditCharacterMenu(user)
	return 1