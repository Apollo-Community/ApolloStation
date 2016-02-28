/datum/character/Topic(href, href_list)
	var/mob/user = usr

	if(!user)	return

	switch( href_list["character"] )
		if( "open_whitelist_forum" )
			if(config.forumurl)
				user << link(config.forumurl)
			else
				user << "<span class='danger'>The forum URL is not set in the server configuration.</span>"
				return

		if( "switch_menu" )
			SwitchMenuProcess( user, href_list )
			return 1

		if( "disabilities_menu" )
			DisabilitiesMenuProcess( user, href_list )
			return 1

		if( "records_menu" )
			RecordsMenuProcess( user, href_list )
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


/datum/character/proc/SwitchMenuProcess( mob/user, list/href_list )
/*	EditCharacterMenuDisable( user )
	JobChoicesMenuDisable( user )
	RecordsMenuDisable( user )
	AntagOptionsMenuDisable( user )*/

	switch( href_list["task"] )
		if( "edit_character_menu" )
			EditCharacterMenu( user )
		if( "records_menu" )
			RecordsMenu( user )
		if( "job_menu" )
			JobChoicesMenu( user )
		if( "antag_options_menu" )
			AntagOptionsMenu( user )
