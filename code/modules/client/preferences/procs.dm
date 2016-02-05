/datum/preferences/New( client/C )
	if(istype(C))
		client = C
		if(!IsGuestKey(client.key))
			if(!loadPreferences())
				return
			if(!loadCharacters())
				return

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if( !selected_character )
		return

	return selected_character.GetJobDepartment( job, level )

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	if( !selected_character )
		return

	return selected_character.GetPlayerAltTitle( job )

/datum/preferences/proc/beSpecial()
	if( !selected_character )
		return

	return selected_character.job_antag

/datum/preferences/proc/savePreferences()
	if( !client )
		return 0

	if ( IsGuestKey( client.ckey ))
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/sql_ckey = ckey( client.ckey )

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM preferences WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			world << "Invalid sql_id!"
			return

	// Ckey join date
	var/sql_join_date = sql_sanitize_text( joined_date )

	// game-preferences
	var/sql_OOC_color = sanitize_hexcolor( OOC_color )

	// UI prefs
	var/sql_UI_style = sql_sanitize_text( UI_style )
	var/sql_UI_color = sanitize_hexcolor( UI_style_color )
	var/sql_UI_alpha = sanitize_integer( UI_style_alpha, 0, 255, 255 )

	// Preference toggleables
	var/sql_toggles = sanitize_integer( toggles, 0, TOGGLES_DEFAULT, TOGGLES_DEFAULT )

	// Saved characters
	var/sql_select_char = "None"
	if( selected_character )
		sql_select_char = sql_sanitize_text( selected_character.name )

	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE preferences SET OOC_color = '[sql_OOC_color]', UI_style = '[sql_UI_style]', UI_style_color = '[sql_UI_color]', UI_style_alpha = '[sql_UI_alpha]', toggles = '[sql_toggles]', last_character = '[sql_select_char]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO preferences (id, ckey, joined_date, OOC_color, UI_style, UI_style_color, UI_style_alpha, toggles, last_character) VALUES (null, '[sql_ckey]', '[sql_join_date]', '[sql_OOC_color]', '[sql_UI_style]', '[sql_UI_color]', '[sql_UI_alpha]', '[sql_toggles]', '[sql_select_char]')")

		query_insert.Execute()

	return 1

/datum/preferences/proc/loadPreferences()
	if( !client )
		return 0

	if ( IsGuestKey( client.ckey ))
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/sql_ckey = ckey( client.ckey )

	var/DBQuery/query = dbcon.NewQuery("SELECT joined_date, OOC_color, UI_style, UI_style_color, UI_style_alpha, toggles, last_character FROM preferences WHERE ckey = '[sql_ckey]'")
	query.Execute()

	while(query.NextRow())
		joined_date = query.item[1]
		OOC_color = query.item[2]
		UI_style = query.item[3]
		UI_style_color = query.item[4]
		UI_style_alpha = text2num( query.item[5] )
		toggles = text2num( query.item[6] )
		var/selected_char_name = query.item[7]

		if( selected_char_name in characters )
			selected_character = characters[selected_char_name]
		else
			selected_character = null

	return 1

/datum/preferences/proc/saveCharacter()
	if( !selected_character )
		return

	return selected_character.saveCharacter()

/datum/preferences/proc/loadCharacters()
	return 1
