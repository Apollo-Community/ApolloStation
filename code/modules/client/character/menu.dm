/datum/character/proc/process_links( mob/user, list/href_list )
	if(!user)	return

	if(!istype(user, /mob/new_player))	return

	switch( href_list["character"] )
		if( "open_whitelist_forum" )
			if(config.forumurl)
				user << link(config.forumurl)
			else
				user << "<span class='danger'>The forum URL is not set in the server configuration.</span>"
				return

		if( "disabilities_menu" )
			DisabilitiesMenuProcess( user, href_list )
			return 1

		if( "records_menu" )
			RecordsMenuProcess( user, href_list )
			return 1

		if( "flavor_text_menu" )
			FlavorTextMenuProcess( user, href_list )
			return 1

		if( "job_choices_menu")
			JobChoicesMenuProcess( user, href_list )
			return 1

		if( "antag_options_menu" )
			AntagOptionsMenuProcess( user, href_list )
			return 1

		if( "edit_character" )
			EditCharacterMenuProcess( user, href_list )
			return 1

		if( "species_menu" )
			SpeciesMenuProcess( user, href_list )
			return 1

	return 1