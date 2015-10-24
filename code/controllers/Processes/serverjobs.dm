/datum/controller/process/inactivity/setup()
	name = "inactivity"
	schedule_interval = 600 // Once every minute (approx.)
	cpu_threshold = 10

/datum/controller/process/inactivity/doWork()
	if(config.kick_inactive)
		for(var/client/C in clients)
			if(!C.holder && C.is_afk(config.kick_inactive MINUTES))
				if(!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					C << "<SPAN CLASS='warning'>You have been inactive for more than [config.kick_inactive] minute\s and have been disconnected.</SPAN>"
					del(C)	// Don't qdel, cannot override finalize_qdel behaviour for clients.
			//scheck() 				Not really nessesary

/datum/controller/process/statplayers/setup()
	name = "statplayers"
	schedule_interval = 50 //runs every 5 seconds (subject to change)
	cpu_threshold = 10

/datum/controller/process/statplayers/doWork()
	// I kinda don't wana rebuild the list everytime, but probably the easiest way to get around it
	stat_player_list.Cut()
	for(var/client/C in clients)
		var/entry
		if(C.holder && C.holder.fakekey)								//Enables support for stealth mode
			stat_player_list.Add(C.ckey)
			stat_player_list[C.ckey] = "Player"
			continue
		else if(C.holder && (R_MOD & C.holder.rights))				entry = "Mod"
		else if(C.holder && (R_ADMIN & C.holder.rights))			entry = "Admin"
		else if(C.holder && (R_DEBUG & C.holder.rights))			entry = "Dev"
		else if(C.donator)																		entry = "Donator"
		else																									entry = "Player"
		if(C.afk)																							entry += "   AFK"	//pitty tabs ruin the column

		stat_player_list.Add(C.ckey)				//Associated lists are silly, stat_player_list.Add(C.ckey = entry) assumes you're calling .Add() with arguments
		stat_player_list[C.ckey] = entry

	stat_player_list = sortList(stat_player_list) 	//Prutty. (lets just hope it works)
