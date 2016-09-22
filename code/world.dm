var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()

	makeDatumRefLists()
	load_configuration()

	qdel(src)


/world
	name = "Apollo Station"
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session

#define RECOMMENDED_VERSION 510
/world/New()
	// if we're being called by command line then lets do stuff!
	if(params.len)
		world.log << "Command-line parameters:"
		for(var/p in params)	world.log << "[p] = [params[p]]"
		if(params["hub"])
			visibility = 1
			world.log << "Setting server visibility to 1."
		if(params["genmap"])
			world.log << "Geneating web maps..."
			generate_every_map()

	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "[log_end]\n[log_end]\nStarting up. [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]"
	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this server. Please update BYOND"

	config.post_load()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	if(config.server_name)
		world.name = config.server_name

	if(config && config.log_runtime)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	callHook("startup")
	//Emergency Fix
	load_mods()
	//end-emergency fix

	src.update_status()
	. = ..()

	// Set up roundstart seed list. This is here because vendors were
	// bugging out and not populating with the correct packet names
	// due to this list not being instantiated.
	populate_seed_list()

	// Create autolathe recipes, as above.
	populate_lathe_recipes()

	processScheduler = new
	master_controller = new /datum/controller/game_controller()

	spawn(1)
		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()
		master_controller.setup()
		spawn(0)
			log_debug("Starting discord bot background process.")
			shell("python3.6 scripts/discord_bot.py")
			log_debug("Returning from discord bot background proces")
		universe.load_date()
		getFormsFromWiki() //Load some data form the wiki page
		sleep_offline = 1 // go to sleep after the controllers are all set up

	#ifdef PRECISE_TIMER_AVAILABLE
	world.log << "btime.[world.system_type==MS_WINDOWS?"dll":"so"] will be used for timer"
	#else
	world.log << "## ERROR: btime.[world.system_type==MS_WINDOWS?"dll":"so"] could not be found, using legacy timer"
	#endif

	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()

#undef RECOMMENDED_VERSION

	return

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	log_debug("TOPIC: \"[T]\", from:[addr], master:[master], key:[key][log_end]")
	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (copytext(T,1,7) == "sitest")	//returns num of players, round duration (starting at 0:00)
		return list2params(list("players" = clients.len, "time" = worldtime2text(bonus_time = 0)))

	else if (copytext(T,1,7) == "status")
		var/input[] = params2list(T)
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config.abandon_allowed
		s["enter"] = config.enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["stationtime"] = worldtime2text()

		if(input["status"] == "2")
			var/list/players = list()
			var/list/admins = list()

			for(var/client/C in clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue
					admins[C.key] = C.holder.rank
				players += C.key

			s["players"] = players.len
			s["playerlist"] = list2params(players)
			s["admins"] = admins.len
			s["adminlist"] = list2params(admins)
		else
			var/n = 0
			var/admins = 0

			for(var/client/C in clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue	//so stealthmins aren't revealed by the hub
					admins++
				s["player[n]"] = C.key
				n++

			s["players"] = n
			s["admins"] = admins

		return list2params(s)


	if(copytext(T,1,9) == "adminmsg")
		var/input[] = params2list(copytext(T,9))
		//Check if messages is coming from local host for security reasons.
		if (addr != "127.0.0.1")
			message_admins("TOPIC: WARNING: [addr] tried to fake an admin command to the server! Please contact a developer")
			command_discord("staff", "Server", "WARNING:[addr] tried to fake an admin command to the server! Please contact a developer.")
			return
		var/message = input["text"]
		var/target = lowertext(input["target"])
		var/admin = input["admin"]

		//get the target and send PM
		for(var/client/C in clients)
			if(C.ckey == target)
				//Code to send PMS....
				discord_admin(C, admin, message, 0)
				break

	if(copytext(T,1,6) == "gencom")	//Message received from general channel in discord (non admin message)
		var/input[] = params2list(copytext(T,6))
		if (addr != "127.0.0.1")
			message_admins("TOPIC: WARNING: [addr] tried to fake an admin command to the server! Please contact a developer")
			command_discord("staff", "Server", "WARNING:[addr] tried to fake an admin command to the server! Please contact a developer.")
			return
		var/command = input["command"]
		var/message = ""
		switch(command)
			if("staffwho")
				for(var/client/c in admins)
					message += "[c.ckey] "
				return = admins_string
			if("players")
				for(var/client/c in clients)
					message += "[c.ckey] "
			if("uptime")
				message = worldtime2text()
			else
				return
		command_discord("general", "Server", message)


	if(copytext(T,1,6) == "modcom")	//Message received from staff channel in discord mod/admin message.
		var/input[] = params2list(copytext(T,6))
		if (addr != "127.0.0.1")
			message_admins("TOPIC: WARNING: [addr] tried to fake an admin command to the server! Please contact a developer")
			command_discord("staff", "server", "WARNING:[addr] tried to fake an admin command to the server! Please contact a developer.")
			return
		var/command = input["command"]
		switch(command)
			if("update")
				update_server_command(input["author"])
				command_discord("staff", "server", "[input["author"]] called server update via discord.")
			else
				return

	/*
	if(copytext(T,1,9) == "adminmsg")					//This recieves messages from slack (/pm command) and processes it before updating slack chat
		var/input[] = params2list(copytext(T,9))
		//security check

		if(fexists("config/slack.txt"))
			if(input["token"] != file2text("config/slack.txt"))
				message_admins("TOPIC: WARNING: [addr] tried to fake an admin message! Please contact a developer")
				return
		else	return

		log_debug(input["token"])			//Just for testing

		var/message = input["text"]
		var/target = lowertext(input["target"])
		var/admin = input["admin"]

		//get the target and send PM
		for(var/client/C in clients)
			if(C.ckey == target)
				//Code to send PMS....
				slack_admin(C, admin, message, 0)
				break
	*/

	else if(copytext(T,1,4) == "age")
		var/input[] = params2list(T)
		if(input["key"] != config.comms_password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)
				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr
			return "Bad Key"

		var/age = get_player_age(input["age"])
		if(isnum(age))
			if(age >= 0)
				return "[age]"
			else
				return "Ckey not found"
		else
			return "Database connection failed or not set up"


/world/Reboot(var/reason)
	/*spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
		*/

	processScheduler.stop()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

	..(reason)

/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			log_misc("Saved mode is '[master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode


/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadforumsql("config/forumdbconfig.txt")

/hook/startup/proc/loadMods()
	world.load_mods()
	world.load_mentors() // no need to write another hook.
	return 1

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			error("Failed to load config/mods.txt")
		else
			var/list/lines = text2list(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Moderator"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(directory[ckey])

/world/proc/load_mentors()
	if(config.admin_legacy_system)
		var/text = file2text("config/mentors.txt")
		if (!text)
			error("Failed to load config/mentors.txt")
		else
			var/list/lines = text2list(text, "\n")
			for(var/line in lines)
				if (!line)
					continue
				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Mentor"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(directory[ckey])

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		if(config.forumurl)
			s += "<a href=\"[config.forumurl]\">"
		else
			s += "<a href=\"https://apollo-community.org\">"
		s += "<big><b>[config.server_name]</b></big>"
		s += "</a>\]"

		if( !ticker )
			s += "  - <b>STARTING</b> -"
		s += "<br>\["

	if( clients )
		s += "Players: [clients.len] / [config.player_soft_cap]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the feedback database."
	else
		world.log << "Feedback database connection established."
	return 1

proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
