/**********************
 * ENDGAME STUFF
 **********************/

 // Universal State
 // Handles stuff like space icon_state, constants, etc.
 // Essentially a policy manager.  Once shit hits the fan, this changes its policies.
 // Called by master controller.

/proc/set_date( var/year, var/month, var/day )
	if( !year || year < START_YEAR )
		return

	if( !month || month < 1 || month > 12 )
		month = 1

	if( !day || day < 1 )
		day = 1

	universe.date = list( "year" = year, "month" = month, "day" = day )

 // Default shit.
/datum/universal_state
	// Just for reference, for now.
	// Might eventually add an observatory job.
	var/name = "C-137"
	var/desc = "Things are about as normal as they've ever been."

	var/list/date = list()

	// Sets world.turf, replaces all turfs of type /turf/space.
	var/space_type         = /turf/space

	// Replaces all turfs of type /turf/space/transit
	var/transit_space_type = /turf/space/transit

	// Chance of a floor or wall getting damaged [0-100]
	// Simulates stuff getting broken due to molecular bonds decaying.
	var/decay_rate = 0

	var/round_number = 0 // How many days has it been since Jan 1, 2560?

/datum/universal_state/proc/load_date()
	var/max_attempts = 5

	for( var/attempts = 1, attempts <= max_attempts, attempts++ )
		date = loadFromDB()

		var/message = "Loaded date: "

		for( var/i in date )
			message += "[i] "

		log_debug( "[message]" )

		if( !date )
			log_debug( "Loaded date does not exist!" )
			continue

		if( date.len != 3 )
			log_debug( "Loaded date was [date.len] in length!" )
			continue

		var/days = daysTilDate( list( "year" = START_YEAR, "month" = 1, "day" = 1 ), date )

		if( days <= 0 )
			log_debug( "Loaded date was [days] days behind the default date!" )
			continue

		round_number = days
		log_debug( "Loaded date: [print_date( date )]!" )
		date = progessDate( date )
		log_debug( "Date progressed: [print_date( date )]!" )
		return

	date = list( "year" = START_YEAR, "month" = 1, "day" = 1 )

	log_debug( "Failed to load the universe date after [max_attempts] attempts!" )

// Returns the universe datetime in format "YYYY-MM-DD HH:MM:SS"
/datum/universal_state/proc/getDateTime()
	var/timestamp = "[date[1]]-[ date[2] < 10 ? date[2] : add_zero( date[2] )]-[ date[3] < 10 ? date[3] : add_zero( date[3] )]"

	var/seconds = world.time / 10 % 60
	timestamp += " [worldtime2text()]:[ seconds < 10 ? seconds : add_zero( seconds )]"

	return timestamp

/datum/universal_state/proc/getYear()
	if( !date || date.len != 3 )
		return START_YEAR

	return date[1]

/datum/universal_state/proc/saveToDB()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		log_debug( "Could not save the universe date!" )
		return

	if( daysTilDate( date, loadFromDB() ) >= 0 ) // If our database date is ahead of IC date
		log_debug( "Didn't save because universe date was reset!" )
		return

	var/sql_name = sql_sanitize_text( name )
	var/sql_date = html_encode( list2params( date ))

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM universe WHERE name = '[sql_name]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		break

	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			log_debug( "SQL ID is invalid!" )
			return

	var/message = "Saved date: "

	for( var/i in date )
		message += "[date[i]] "

	log_debug( "[message]" )

	if(sql_id)
		var/DBQuery/query_update

		query_update = dbcon.NewQuery("UPDATE universe SET name = '[sql_name]', ic_date = '[sql_date]' WHERE id = '[sql_id]'")
		query_update.Execute()
	else
		var/DBQuery/query_insert

		query_insert = dbcon.NewQuery("INSERT INTO universe (id, name, ic_date) VALUES (null, '[sql_name]', '[sql_date]')")
		query_insert.Execute()

/datum/universal_state/proc/loadFromDB( var/univ_name = "C-137" )
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_debug( "Database is not connected yet!" )
		return

	var/list/D = list( "year" = START_YEAR, "month" = 1, "day" = 1 )

	var/sql_name = sql_sanitize_text( univ_name )

	var/DBQuery/query = dbcon.NewQuery("SELECT ic_date FROM universe WHERE name = '[sql_name]'")
	query.Execute()

	if( !query.NextRow() )
		log_debug( "Could not read the universe date!" )
		return D

	var/list/date_text = params2list( html_decode( query.item[1] ))
	for( var/i in date_text )
		D[i] = text2num( date_text[i] )

	return D

// Actually decay the turf.
/datum/universal_state/proc/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			F.ReplaceWithLattice()
		return

// Return 0 to cause shuttle call to fail.
/datum/universal_state/proc/OnShuttleCall(var/mob/user)
	return 1

// Processed per tick
/datum/universal_state/proc/OnTurfTick(var/turf/T)
	if(decay_rate && prob(decay_rate))
		DecayTurf(T)

// Apply changes when exiting state
/datum/universal_state/proc/OnExit()
	// Does nothing by default

// Apply changes when entering state
/datum/universal_state/proc/OnEnter()
	// Does nothing by default

// Apply changes to a new turf.
/datum/universal_state/proc/OnTurfChange(var/turf/NT)
	return

/datum/universal_state/proc/OverlayAndAmbientSet()
	return

/proc/SetUniversalState(var/newstate,var/on_exit=1, var/on_enter=1)
	if(on_exit)
		universe.OnExit()
	universe = new newstate
	if(on_enter)
		universe.OnEnter()
