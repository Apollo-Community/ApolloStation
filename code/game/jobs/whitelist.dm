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

/proc/get_alien_flag( var/species )
	var/list/aliens = list( "diona" = A_WHITELSIT_DIONA,
							"skrell" = A_WHITELSIT_SKRELL,
							"tajaran" = A_WHITELSIT_TAJARA,
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

	var/a_whitelist = 0
	var/sql_ckey = sql_sanitize_text(ckey(C.key))

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
		var/ckey = ckey(key)

		var/DBQuery/query = dbcon.NewQuery("SELECT id FROM player WHERE ckey = '[ckey]'")
		query.Execute()

		if( !query.NextRow() )
			world << "Could not find '[ckey]' in the player database, and so could not add their whitelist status"
			continue
		else
			world << "<b>Found '[ckey]' in the player database, and are adding their whitelist</b>"

		var/sql = "UPDATE player SET whitelist_flags = '1' WHERE ckey = '[ckey]'"
		var/DBQuery/query_insert = dbcon.NewQuery(sql)
		query_insert.Execute()
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
	var/empty_lines = 0
	for( var/line in raw_whitelist )
		var/list/item = list()
		item = text2list( line, " - " ) // please dont break
		if( item.len == 2 )
			whitelist[item[1]] |= get_alien_flag( "[item[2]]" )
		else
			empty_lines++

	for( var/key in whitelist )
		var/ckey = ckey(key)

		var/DBQuery/query = dbcon.NewQuery("SELECT id FROM player WHERE ckey = '[ckey]'")
		query.Execute()

		var/flags = whitelist[key]
		if( !query.NextRow() )
			world << "Could not find '[ckey]' in the player database, and so could not add their species status of '[flags]'"
			continue
		else
			world << "<b>Found '[ckey]' in the player database, and are adding their species status of '[flags]'</b>"

		var/sql = "UPDATE player SET species_flags = '[flags]' WHERE ckey = '[ckey]'"
		var/DBQuery/query_insert = dbcon.NewQuery(sql)
		query_insert.Execute()
#undef A_WHITELISTFILE
