//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

datum/controller/game_controller
	var/list/shuttle_list	                    // For debugging and VV
	var/datum/ore_distribution/asteroid_ore_map   // For debugging and VV.

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		admin_notice("<span class='danger'>Job setup complete</span>", R_DEBUG)

	//Load order is important as we may need controllers in subsequent controllers
	if(!ticker)						ticker = new /datum/controller/gameticker()
	if(!template_config)			template_config = new /datum/template_config()
	if(!template_controller)		template_controller = new /datum/template_controller()
	if(!dmm_serializer)				dmm_serializer = new /datum/dmm_serializer()
	if(!hanger_controller)			hanger_controller = new /datum/hanger_controller()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/emergency_shuttle_controller()
	if(!shuttle_controller)			shuttle_controller = new /datum/shuttle_controller()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	setup_objects()
	setupgenetics()

	//Place templates and spawn in shuttles
	template_controller.PlaceTemplates()
	shuttle_controller.setup()
	// Place the construction station/derelict
	universe.loadConstructionStation()

	// Pick a new race to unwhitelist for today's week
	var/deciseconds_in_week = DECISECONDS_IN_SECOND*SECONDS_IN_WEEK
	var/selected_race = ((world.realtime/deciseconds_in_week) % whitelisted_species.len)
	if( selected_race && selected_race < whitelisted_species.len )
		unwhitelisted_alien = whitelisted_species[selected_race]
	else
		unwhitelisted_alien = "Wryn"

	whitelisted_species -= unwhitelisted_alien

	transfer_controller = new

datum/controller/game_controller/proc/setup_objects()
	admin_notice("<span class='danger'>Initializing objects</span>", R_DEBUG)
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

	admin_notice("<span class='danger>Initializing areas</span>", R_DEBUG)
	sleep(-1)
	for(var/area/area in all_areas)
		area.initialize()

	admin_notice("<span class='danger'>Initializing pipe networks</span>", R_DEBUG)
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	admin_notice("<span class='danger'>Initializing atmos machinery.</span>", R_DEBUG)
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	// Create the mining ore distribution map.
	// These values determine the specific area that the map is applied to.
	// If you do not use the official Baycode asteroid map, you will need to change them.
	asteroid_ore_map = new /datum/ore_distribution()
	asteroid_ore_map.populate_distribution_map()

	// Set up antagonists.
//	populate_antag_type_list()

	//Set up spawn points.
	populate_spawn_points()

	admin_notice("<span class='danger'>Initializations complete.</span>", R_DEBUG)
	sleep(-1)
