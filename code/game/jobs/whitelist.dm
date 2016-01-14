/client/proc/add_whitelist()
	set category = "Admin"
	set name = "Write to Whitelist"
	set desc = "Adds a user to any whitelist available in the directory mid-round."

	if(!check_rights(R_ADMIN|R_MOD))
		return

	var/client/input = input("Please, select a player!", "Add User to Whitelist") as null|anything in sortKey(clients)
	if(!input)
		return
	else
		input = input.ckey

	var/type = input("Select what type of whitelist", "Add User to Whitelist") as null|anything in list( "Whitelist", "Alien Whitelist", "Donators" )
	switch(type)
		if("Whitelist")
			if( add_command_whitelist( input, WHITELIST_COMMAND ))
				message_admins("[key_name_admin(usr)] has whitelisted [input].")
			else
				usr << "<span class='danger'>Could not add [input] to the whitelist. Perhaps they're already whitelisted?</span>"
		if("Alien Whitelist")
			var/race = input("Which species?") as null|anything in whitelisted_species
			if(!race)
				return
			if( add_alien_whitelist( input, get_alien_flag( race )))
				message_admins("[key_name_admin(usr)] has whitelisted [input] for [race].")
			else
				usr << "<span class='danger'>Could not add [race] to the whitelist of [input]. Perhaps they've already got that one?</span>"
		if("Donators")
			var/tier = input("Which tier?") as null|anything in list( 1, 2 )
			if( !tier )
				return
			if( setDonator( input, tier ))
				message_admins("[key_name_admin(usr)] has added [input] as a donator.")
			else
				usr << "<span class='danger'>Could not add [input] to donators. Perhaps they're already set?</span>"

/proc/get_whitelist( client/C /*, var/rank*/)
	if( !C )
		return 0

	if( C.holder )
		return WHITELIST_TOTAL

	establish_db_connection()
	if(!dbcon.IsConnected())
		return null

	var/whitelist = 0
	var/sql_ckey = sql_sanitize_text(ckey(C.key))

	var/DBQuery/query = dbcon.NewQuery("SELECT whitelist_flags FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		whitelist = text2num(query.item[1])

	return whitelist

/proc/is_whitelisted(mob/M , var/role = "command" )
	if( !M )
		return 0

	var/list/roles = list( "command" = WHITELIST_COMMAND )

	var/whitelist = 0
	if( M.client )
		whitelist = get_whitelist( M.client )

	if( whitelist & roles[lowertext( role )] )
		return 1
	return 0

/proc/add_command_whitelist( var/key, var/flags = 0 )
	if( !key )
		return 0

	var/ckey = ckey(key)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM player WHERE ckey = '[ckey]'")
	query.Execute()

	if( !query.NextRow() )
		return 0

	var/sql = "UPDATE player SET whitelist_flags = '[flags]' WHERE ckey = '[ckey]'"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()

	return 1

/proc/get_alien_flag( var/species )
	var/list/aliens = list( "diona" = A_WHITELSIT_DIONA,
							"skrell" = A_WHITELSIT_SKRELL,
							"tajara" = A_WHITELSIT_TAJARA,
							"unathi" = A_WHITELSIT_UNATHI,
							"wryn" = A_WHITELSIT_WRYN )
	var/alien_flag = 0

	if( lowertext( species ) in aliens )
		alien_flag = aliens[lowertext( species )]

	return alien_flag

/proc/get_alien_whitelist( client/C )
	if( !C )
		return 0

	if( !config.usealienwhitelist )
		return A_WHITELIST_TOTAL

	if( C.holder )
		return A_WHITELIST_TOTAL

	establish_db_connection()
	if(!dbcon.IsConnected())
		return null

	return get_alien_whitelist_flags( C.ckey )

/proc/get_alien_whitelist_flags( var/key )
	if( !key )
		return 0

	var/a_whitelist = 0
	var/sql_ckey = sql_sanitize_text(ckey(key))

	var/DBQuery/query = dbcon.NewQuery("SELECT species_flags FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		a_whitelist = text2num(query.item[1])

	return a_whitelist

/proc/is_alien_whitelisted(mob/M, var/species)
	if( !M )
		return 0

	var/a_whitelist = 0
	if( M.client )
		a_whitelist = get_alien_whitelist( M.client )

	if( a_whitelist & get_alien_flag( species ))
		return 1

	return 0

/proc/add_alien_whitelist( var/key, var/flags = 0)
	if( !key )
		return 0

	var/ckey = ckey(key)

	var/DBQuery/query = dbcon.NewQuery("SELECT species_flags FROM player WHERE ckey = '[ckey]'")
	query.Execute()

	if( !query.NextRow() )
		return 0

	var/existing_flags = get_alien_whitelist_flags( key )

	if( existing_flags & flags )
		return 0

	existing_flags |= flags

	var/sql = "UPDATE player SET species_flags = '[existing_flags]' WHERE ckey = '[ckey]'"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()

	return 1

#define WHITELISTFILE "data/whitelists/whitelist.txt"
/proc/convert_whitelist()
	establish_db_connection()
	if(!dbcon.IsConnected())
		world << "Database not connected!"
		return null

	var/list/whitelist = list()
	whitelist = file2list( WHITELISTFILE )

	if( !whitelist.len )
		return

	for( var/key in whitelist )
		if( add_command_whitelist( key, WHITELIST_COMMAND ))
			world << "<b>Found '[key]' in the player database, and are adding their whitelist</b>"
		else
			world << "Could not find '[key]' in the player database, and so could not add their whitelist status"


#undef WHITELISTFILE

#define A_WHITELISTFILE "data/whitelists/alienwhitelist.txt"
/proc/convert_alienwhitelist()
	establish_db_connection()
	if(!dbcon.IsConnected())
		world << "Database not connected!"
		return null

	var/list/raw_whitelist = list()
	raw_whitelist = file2list( A_WHITELISTFILE, "\n" )

	if( !raw_whitelist.len )
		return

	var/list/whitelist = list()
	for( var/line in raw_whitelist )
		var/list/item = list()
		item = text2list( line, " - " ) // please dont break
		if( item.len == 2 )
			whitelist[item[1]] |= get_alien_flag( "[item[2]]" )

	for( var/key in whitelist )
		if( add_alien_whitelist( key, whitelist[key] ))
			world << "<b>Found '[key]' in the player database, and are adding their species status of '[whitelist[key]]'</b>"
		else
			world << "Could not find '[key]' in the player database, and so could not add their species status of '[whitelist[key]]'"

#undef A_WHITELISTFILE
