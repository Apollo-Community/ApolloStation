/**********************
 * ENDGAME STUFF
 **********************/

 // Universal State
 // Handles stuff like space icon_state, constants, etc.
 // Essentially a policy manager.  Once shit hits the fan, this changes its policies.
 // Called by master controller.

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

/datum/universal_state/New()
	..()

	spawn( 10 )
		loadFromDB()

		if( !date || date.len < 3 )
			date = list( 2560, 1, 1 )

		handleDateProgression()

/datum/universal_state/Destroy()
	saveToDB()

	..()

// Returns the universe datetime in format "YYYY-MM-DD HH:MM:SS"
/datum/universal_state/proc/getDateTime()
	var/timestamp = "[date[1]]-[ date[2] < 10 ? date[2] : add_zero( date[2] )]-[ date[3] < 10 ? date[3] : add_zero( date[3] )]"

	var/seconds = world.time / 10 % 60
	timestamp += " [worldtime2text()]:[ seconds < 10 ? seconds : add_zero( seconds )]"

	return timestamp

/datum/universal_state/proc/handleDateProgression()
	var/days = date[3]
	var/month = date[2]
	var/year = date[1]

	days++

	if( days > getMonthDays( month ))
		days = 1
		month++

	if( month > 12 )
		month = 1
		year++

	date = list( year, month, days )

/datum/universal_state/proc/saveToDB()
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
			return

	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update

		query_update = dbcon.NewQuery("UPDATE universe SET name = '[sql_name]', ic_date = '[sql_date]' WHERE id = '[sql_id]'")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert

		query_insert = dbcon.NewQuery("INSERT INTO universe (id, name, ic_date) VALUES (null, '[sql_name]', '[sql_date]')")
		query_insert.Execute()

/datum/universal_state/proc/loadFromDB( var/univ_name = "C-137" )
	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_name = sql_sanitize_text( univ_name )

	var/DBQuery/query = dbcon.NewQuery("SELECT ic_date FROM universe WHERE name = '[sql_name]'")
	query.Execute()

	if( !query.NextRow() )
		date = list( 2560, 1, 1 )
		name = univ_name
		world << "Could not load from database!"
		return

	var/list/date_text = params2list( html_decode( query.item[1] ))
	if( date_text && date_text.len >= 3 )
		date = list( text2num( date_text[1] ), text2num( date_text[2] ), text2num( date_text[3] ))

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
