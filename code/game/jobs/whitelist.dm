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

	var/list/aliens = list( "diona" = A_WHITELSIT_DIONA,
							"skrell" = A_WHITELSIT_SKRELL,
							"tajara" = A_WHITELSIT_TAJARA,
							"unathi" = A_WHITELSIT_UNATHI,
							"wryn" = A_WHITELSIT_WRYN )

	var/a_whitelist = 0
	if( M.client )
		a_whitelist = get_alien_whitelist( M.client )

	if( a_whitelist & aliens[lowertext( species )] )
		return 1

	return 0

#undef WHITELISTFILE
