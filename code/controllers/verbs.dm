//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/*
/client/proc/print_random_map()
	set category = "Debug"
	set name = "Display Random Map"
	set desc = "Show the contents of a random map."

	if(!holder)	return

	var/datum/random_map/choice = input("Choose a map to debug.") as null|anything in random_maps
	if(!choice)
		return
	choice.display_map(usr)


/client/proc/create_random_map()
	set category = "Debug"
	set name = "Create Random Map"
	set desc = "Create a random map."

	if(!holder)	return

	var/map_datum = input("Choose a map to create.") as null|anything in typesof(/datum/random_map)-/datum/random_map
	if(!map_datum)
		return
	var/seed = input("Seed? (default null)")  as text|null
	var/tx =    input("X? (default 1)")       as text|null
	var/ty =    input("Y? (default 1)")       as text|null
	var/tz =    input("Z? (default 1)")       as text|null
	new map_datum(seed,tx,ty,tz)
*/
/client/proc/restart_controller(controller in list("Supply"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	usr = null
	src = null
	switch(controller)
		if("Supply")
			supply_controller.process()
			feedback_add_details("admin_verb","RSupply")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return
/*
/client/proc/debug_antagonist_template(antag_type in all_antag_types)
	set category = "Debug"
	set name = "Debug Antagonist"
	set desc = "Debug an antagonist template."

	var/datum/antagonist/antag = all_antag_types[antag_type]
	if(antag)
		usr.client.debug_variables(antag)
		message_admins("Admin [key_name_admin(usr)] is debugging the [antag.role_text] template.")
*/
//A list that stores all of the controllers in the game.
/var/global/list/active_controllers = list()

//Manages all controllers in the game so we can easily access them from debug_controller()
/datum/controller/New()
	active_controllers += src

/datum/controller/Del()
	active_controllers -= src

/client/proc/debug_controller()
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return

	var/controller = input("Which controller?") in active_controllers	//Removes the stupid special casing implemented previously.

	debug_variables(controller)

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return

// Debug verb for antagonist update
/client/proc/debug_antag(item in list("Faction controller", "Contract Ticker"))
	set category = "Debug"
	set name = "Debug Antagonists"
	set desc = "Debug antagonist-related stuff"

	if(!holder)	return
	switch(item)
		if("Faction controller")
			debug_variables(faction_controller)
		if("Contract Ticker")
			debug_variables(contract_ticker)