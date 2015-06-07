//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0
var/global/machine_processing_killed = 0

var/global/lag_free = 0

datum/controller/game_controller
	var/processing = 0
	var/breather_ticks = 3		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/air_cost 		= 0
	var/sun_cost		= 0
	var/mobs_cost		= 0
	var/diseases_cost	= 0
	var/machines_cost	= 0
	var/objects_cost	= 0
	var/networks_cost	= 0
	var/powernets_cost	= 0
	var/nano_cost		= 0
	var/events_cost		= 0
	var/ticker_cost		= 0
	var/total_cost		= 0


	var/last_thing_processed

	var/list/shuttle_list	                    // For debugging and VV
	var/datum/ore_distribution/asteroid_ore_map // For debugging and VV.


datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			Recover()
			del(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()


	if(!ticker)						ticker = new /datum/controller/gameticker()
	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/emergency_shuttle_controller()
	if(!shuttle_controller)			shuttle_controller = new /datum/shuttle_controller()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	/* Used for away missions - no point running it at the moment.
	spawn(20)
		createRandomZlevel()
	*/

	setup_objects()
	setupgenetics()
	setupfactions()
	setup_economy()
	SetupXenoarch()

	transfer_controller = new

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	spawn(0)
		if(ticker)
			ticker.pregame()

	lighting_controller.initializeLighting()

datum/controller/game_controller/proc/setup_objects()
	world << "\red \b Initializing objects"
	sleep(-1)
	for(var/obj/object in world)
		object.initialize()

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/vent_pump/T in world)
		T.broadcast_status()
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/T in world)
		T.broadcast_status()

	//Create the mining ore distribution map.
	asteroid_ore_map = new /datum/ore_distribution()
	asteroid_ore_map.populate_distribution_map()

	//Shitty hack to fix mining turf overlays, for some reason New() is not being called.
/*
	for(var/turf/simulated/floor/plating/airless/asteroid/T in world)
		T.updateMineralOverlays()
		T.name = "asteroid"
*/

	//Set up spawn points.
	populate_spawn_points()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	processing = 1
	spawn(0)

		while(1)	//far more efficient than recursively calling ourself
			if(!Failsafe)	new /datum/controller/failsafe()

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 100
			last_tick_timeofday = currenttime

			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				spawn(0)
					vote.process()
					transfer_controller.process()
					shuttle_controller.process()
					process_newscaster()

					//MAKING OOC ANNOUNCEMENTS
					announcements()

				sleep(1)

				//AIR
				spawn(0)
					if(!air_processing_killed)
						timer = world.timeofday
						air_master.Tick()
						air_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//SUN
				spawn(0)
					timer = world.timeofday
					sun.calc_position()
					sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				spawn(0)
					timer = world.timeofday
					for(var/mob/M in world)	//only living mobs have life processes
						M.Life()
					mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//DISEASES
				spawn(0)
					timer = world.timeofday
					for(var/datum/disease/D in active_diseases)
						D.process()
					diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES FIRST HALF
				spawn(0)
					timer = world.timeofday
					process_machines_process(1,round(machines.len / 2))
					machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				spawn(0)
					timer = world.timeofday
					for(var/obj/object in processing_objects)
						object.process()
					objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				spawn(0)
					if(!pipe_processing_killed)
						timer = world.timeofday
						for(var/datum/pipe_network/network in pipe_networks)
							network.process()
						networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				spawn(0)
					timer = world.timeofday
					for(var/datum/powernet/P in powernets)
						P.reset()
					powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//NANO UIS
				spawn(0)
					timer = world.timeofday
					for(var/datum/nanoui/ui in nanomanager.processing_uis)
						ui.process()
					if(STUI.processing)		// Only do this if there is something processing.
						for(var/datum/nanoui/ui in nanomanager.processing_uis)	// need to wait until all UI's are processed
							if(ui.title == "STUI")
								STUI.processing.Remove(ui.user.STUI_log)

					nano_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//TICKER
				spawn(0)
					timer = world.timeofday
					ticker.process()
					ticker_cost = (world.timeofday - timer) / 10

				//EVENTS
				spawn(0)
					timer = world.timeofday
					event_manager.process()
					events_cost = (world.timeofday - timer) / 10

				//MACHINES SECOND HALF
				spawn(0)
					timer = world.timeofday
					process_machines_process(round(machines.len / 2)+1, machines.len)
					machines_cost += (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + objects_cost + networks_cost + powernets_cost + nano_cost + events_cost + ticker_cost

				sleep( minimum_ticks - max(world.timeofday-start_time,0))

			else
				sleep(10)

datum/controller/game_controller/proc/process_machines_process(var/start, var/end)
//start and end added to stagger machine processing as a test
	if(machine_processing_killed)
		return

	while(start<=end && end <=machines.len)			//Supresses run-time but less efficient.
		var/obj/machinery/Machine = machines[start]
		if(Machine.process() != PROCESS_KILL)
			if(Machine)
				if(Machine.use_power)
					Machine.auto_use_power()
				start++
				continue
		machines.Cut(start,start+1)

datum/controller/game_controller/proc/announcements()
	if( controller_iteration % 300 == 0 )// Make an announcement every 10 minutes

		//Tagging this in here as little cheaty way to sort machine list every 10mins.
		machines = dd_sortedObjectList(machines)

		world << pick(	"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Come join our <a href='http://steamcommunity.com/groups/apcom'>steam group</a> for event notifications and for playing games outside of a space station!</font><br></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Make sure to check out our <a href='http://apollo-community.org/'>forums</a>. Many people post many important things there!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Be sure check out our <a href='https://github.com/stuicey/AS_Project/'>source repository</a>. We're always welcoming new developers, and we'd love you have you on board!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Feel free to come and hop on our <a href='http://apollo-community.org/viewforum.php?f=32'>teamspeak</a> and chat with us!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Make sure to read the <a href='http://apollo-community.org/viewtopic.php?f=4&t=6'>full rules</a>, otherwise you may get in trouble!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> We have community meetings every Saturday at 4 PM EST in our <a href='http://apollo-community.org/viewforum.php?f=32'>teamspeak</a>. Got a problem? Bring it up there!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Enjoy the game, and have a great day!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Find a bug or exploit? Let us know on our <a href='https://github.com/stuicey/AS_Project/issues?q=is%3Aopen+is%3Aissue'>bugtracker</a>!<br></font></b>" ,
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Each week, we de-whitelist an alien race so you give them a test drive. This week's alien is: [unwhitelisted_alien]. Go ahead and give 'em a spin!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> We've got an <a href='http://apollo-community.org/viewforum.php?f=42'>IRC channel</a> if you want to chat!<br></font></b>",
						"<font color='green'><big><img src=\ref['icons/misc/news.png']></img></big><b> Nucleations and IPCs are always dewhitelisted!<br></font></b>",
						)
datum/controller/game_controller/proc/Recover()		//Mostly a placeholder for now.
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

