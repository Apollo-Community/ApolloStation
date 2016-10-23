
var/global/datum/shuttle_controller/shuttle_controller

/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing
	var/list/hangers
	var/init_done = 0

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)
		if (shuttle.process_state)
			shuttle.process()


/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()

	var/datum/shuttle/ferry/shuttle
	// Escape shuttle and pods
	shuttle = new/datum/shuttle/ferry/emergency()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.template_path ="maps/templates/shuttles/emergency_shuttle.dmm"
	shuttle.docking_controller_tag = "escape_shuttle"
	shuttle.dock_target_station = "station_dock"
	shuttle.dock_target_offsite = "centcom_dock"
	shuttle.hanger_station = hangers_as["s_hanger_esc"]
	shuttle.hanger_offsite = hangers_as["c_hanger_esc"]
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN
	shuttles["Escape"] = shuttle
	process_shuttles += shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.docking_controller_tag = "escape_pod_1"
	shuttle.dock_target_station = "escape_pod_1_berth"
	shuttle.dock_target_offsite = "escape_pod_1_recovery"
	shuttle.template_path = "maps/templates/shuttles/escape_n.dmm"
	shuttle.hanger_station = hangers_as["s_escape_pod_1"]
	shuttle.hanger_offsite = hangers_as["c_escape_pod_1"]
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN + rand(-30, 60)	//randomize this so it seems like the pods are being picked up one by one
	process_shuttles += shuttle
	shuttles["Escape Pod 1"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.template_path ="maps/templates/shuttles/escape_n2.dmm"
	shuttle.docking_controller_tag = "escape_pod_2"
	shuttle.dock_target_station = "escape_pod_2_berth"
	shuttle.dock_target_offsite = "escape_pod_2_recovery"
	shuttle.hanger_station = hangers_as["s_escape_pod_2"]
	shuttle.hanger_offsite = hangers_as["c_escape_pod_2"]
	shuttle.transit_direction = NORTH
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN + rand(-30, 60)	//randomize this so it seems like the pods are being picked up one by one
	process_shuttles += shuttle
	shuttles["Escape Pod 2"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.template_path ="maps/templates/shuttles/escape_e.dmm"
	shuttle.docking_controller_tag = "escape_pod_3"
	shuttle.dock_target_station = "escape_pod_3_berth"
	shuttle.dock_target_offsite = "escape_pod_3_recovery"
	shuttle.hanger_station = hangers_as["s_escape_pod_3"]
	shuttle.hanger_offsite = hangers_as["c_escape_pod_3"]
	shuttle.transit_direction = EAST
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN + rand(-30, 60)	//randomize this so it seems like the pods are being picked up one by one
	process_shuttles += shuttle
	shuttles["Escape Pod 3"] = shuttle

	//There is no pod 4, apparently.
	//It was lost to metoers duh
	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.template_path ="maps/templates/shuttles/escape_w.dmm"
	shuttle.docking_controller_tag = "escape_pod_5"
	shuttle.dock_target_station = "escape_pod_5_berth"
	shuttle.dock_target_offsite = "escape_pod_5_recovery"
	shuttle.hanger_station = hangers_as["s_escape_pod_5"]
	shuttle.hanger_offsite = hangers_as["c_escape_pod_5"]
	shuttle.transit_direction = WEST
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION_RETURN + rand(-30, 60)	//randomize this so it seems like the pods are being picked up one by one
	process_shuttles += shuttle
	shuttles["Escape Pod 5"] = shuttle

	//give the emergency shuttle controller it's shuttles
	emergency_shuttle.shuttle = shuttles["Escape"]
	emergency_shuttle.escape_pods = list(
		shuttles["Escape Pod 1"],
		shuttles["Escape Pod 2"],
		shuttles["Escape Pod 3"],
		shuttles["Escape Pod 5"],
	)

	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.docking_controller_tag = "supply_shuttle"
	shuttle.template_path = "maps/templates/shuttles/supply.dmm"
	shuttle.dock_target_station = "cargo_bay"
	shuttle.hanger_station = hangers_as["s_hanger_r"]
	shuttle.hanger_offsite = hangers_as["c_hanger_r"]
	shuttles["Supply"] = shuttle
	process_shuttles += shuttle
	supply_controller.shuttle = shuttle

	// Admin shuttles.
	var/datum/shuttle/ferry/admin_shuttle = new/datum/shuttle/ferry()
	admin_shuttle.location = 1
	admin_shuttle.warmup_time = 10
	admin_shuttle.hanger_station = hangers_as["s_hanger_l"]
	admin_shuttle.hanger_offsite = hangers_as["c_hanger_l"]
	admin_shuttle.template_path ="maps/templates/shuttles/cc_transport.dmm"
	admin_shuttle.docking_controller_tag = "centcom_shuttle"
	admin_shuttle.dock_target_station = "centcom_shuttle_dock_airlock"
	admin_shuttle.dock_target_offsite = "centcom_shuttle_bay"
	shuttles["Centcom"] = admin_shuttle
	process_shuttles += admin_shuttle

	var/datum/shuttle/ferry/pizza_shuttle = new/datum/shuttle/ferry()
	pizza_shuttle.location = 1
	pizza_shuttle.warmup_time = 10
	pizza_shuttle.hanger_station = hangers_as["s_hanger_l"]
	pizza_shuttle.hanger_offsite = hangers_as["c_hanger_p"]
	pizza_shuttle.template_path ="maps/templates/shuttles/pizza.dmm"
	pizza_shuttle.docking_controller_tag = "pizza_shuttle"
	pizza_shuttle.dock_target_station = "pizza_shuttle_dock_airlock"
	pizza_shuttle.dock_target_offsite = "pizza_shuttle_bay"
	shuttles["Pizza"] = pizza_shuttle
	process_shuttles += pizza_shuttle

	var/datum/shuttle/ferry/trade_shuttle = new/datum/shuttle/ferry()
	trade_shuttle.location = 1
	trade_shuttle.warmup_time = 10
	trade_shuttle.hanger_station = hangers_as["s_hanger_l"]
	trade_shuttle.hanger_offsite = hangers_as["c_hanger_t"]
	trade_shuttle.template_path ="maps/templates/shuttles/trade.dmm"
	trade_shuttle.docking_controller_tag = "trade_shuttle"
	trade_shuttle.dock_target_station = "trade_shuttle_dock_airlock"
	trade_shuttle.dock_target_offsite = "trade_shuttle_bay"
	shuttles["Trade"] = trade_shuttle
	process_shuttles += trade_shuttle

	var/datum/shuttle/ferry/hippe_shuttle = new/datum/shuttle/ferry()
	hippe_shuttle.location = 1
	hippe_shuttle.warmup_time = 10
	hippe_shuttle.hanger_station = hangers_as["s_hanger_l"]
	hippe_shuttle.hanger_offsite = hangers_as["c_hanger_h"]
	hippe_shuttle.template_path ="maps/templates/shuttles/hippie.dmm"
	hippe_shuttle.docking_controller_tag = "hippie_shuttle"
	hippe_shuttle.dock_target_station = "hippie_shuttle_dock_airlock"
	hippe_shuttle.dock_target_offsite = "hippie_shuttle_bay"
	shuttles["Hippie"] = hippe_shuttle
	process_shuttles += hippe_shuttle

	/*
	//Is this even in ?
	//yea its the cicle shaped shuttle

	shuttle = new()
	shuttle.location = 1
	shuttle.warmup_time = 10	//want some warmup time so people can cancel.
	shuttle.area_offsite = locate(/area/shuttle/administration/centcom)
	shuttle.area_station = locate(/area/shuttle/administration/station)
	shuttle.docking_controller_tag = "admin_shuttle"
	shuttle.dock_target_station = "admin_shuttle_dock_airlock"
	shuttle.dock_target_offsite = "admin_shuttle_bay"
	shuttles["Administration"] = shuttle
	process_shuttles += shuttle
	*/

	//Alien shuttle can only be moved by admins
	var/datum/shuttle/AS = new/datum/shuttle()
	AS.template_path = "maps/templates/shuttles/alien_shuttle.dmm"
	shuttles["Alien"] = AS
	//process_shuttles += shuttle	//don't need to process this. It can only be moved using admin magic anyways.
	//Admin magic can be found ingame under the admin/secrets tap. The shuttle is moved via the jump shuttle command


	// ERT Shuttle
	var/datum/shuttle/ferry/multidock/specops/ERT = new()
	ERT.location = 0 //ERT home base is the Frigate offsite
	ERT.warmup_time = 10
	ERT.template_path ="maps/templates/shuttles/ERT.dmm"
	ERT.hanger_station = hangers_as["f_hanger"]
	ERT.hanger_offsite = hangers_as["s_hanger_c"]
	ERT.docking_controller_tag = "specops_shuttle_port"
	ERT.docking_controller_tag_station = "specops_shuttle_port"
	ERT.docking_controller_tag_offsite = "specops_shuttle_fore"
	ERT.dock_target_station = "specops_centcom_dock"
	ERT.dock_target_offsite = "specops_dock_airlock"
	shuttles["Special Operations"] = ERT
	process_shuttles += ERT

	//Vox Shuttle.
	var/datum/shuttle/multi_shuttle/VS = new/datum/shuttle/multi_shuttle()
	VS.template_path ="maps/templates/shuttles/vox.dmm"
	VS.destinations = list(
		"Port Solars" = hangers_as["s_space_west"],
		"Starboard Solars" = hangers_as["s_space_east"],
		"Fore Side" = hangers_as["s_space_north"],
		"Fore Port Side" = hangers_as["s_space_north_west"],
		"Fore Starboard Side" = hangers_as["s_space_north_east"],
		"Aft Side" = hangers_as["s_space_south"],
		"Aft Port Side" = hangers_as["s_space_south_west"],
		"Aft Starboard Side" = hangers_as["s_space_south_east"]
		)

	VS.announcer = "NDV Icarus"
	VS.arrival_message = "Attention, Apollo, we just tracked a small target bypassing our defensive perimeter. Can't fire on it without hitting the station - you've got incoming visitors, like it or not."
	VS.departure_message = "Your guests are pulling away, Apollo - moving too fast for us to draw a bead on them. Looks like they're heading out of the system at a rapid clip."
	VS.docking_controller_tag = "Vox Shuttle"
	VS.warmup_time = 0
	VS.starting_hanger = hangers_as["c_vox"]
	shuttles["Vox Skipjack"] = VS

	//For when infrantry witn guns is not enough
	var/datum/shuttle/multi_shuttle/MS = new/datum/shuttle/multi_shuttle()
	MS.template_path ="maps/templates/shuttles/Merc.dmm"
	MS.starting_hanger = hangers_as["merc_home"]
	MS.destinations = list(
		"Port Solars" = hangers_as["s_space_west"],
		"Starboard Solars" = hangers_as["s_space_east"],
		"Fore Side" = hangers_as["s_space_north"],
		"Fore Port Side" = hangers_as["s_space_north_west"],
		"Fore Starboard Side" = hangers_as["s_space_north_east"],
		"Aft Side" = hangers_as["s_space_south"],
		"Aft Port Side" = hangers_as["s_space_south_west"],
		"Aft Starboard Side" = hangers_as["s_space_south_east"],
		"In-station Port hanger" = hangers_as["s_hanger_l"],
		"In-station Starboard hanger" = hangers_as["s_hanger_r"]
		)

	MS.announcer = "NDV Icarus"
	MS.arrival_message = "Attention, Apollo, you have a shuttle sized signature approaching the station - looks unarmed to surface scans but we are reading alot of mechanical signatures. We're too far out to intercept - brace for visitors."
	MS.departure_message = "Your visitors are on their way out of the system, Apollo, burning delta-v like it's nothing. Good riddance."
	MS.warmup_time = 0
	MS.docking_controller_tag = "Mech_Merc_Shuttle"
	shuttles["Mech_Mercenary"] = MS

	//Nuke ops shuttle
	var/datum/shuttle/multi_shuttle/NS = new/datum/shuttle/multi_shuttle()
	NS.template_path ="maps/templates/shuttles/nuke_ops.dmm"
	NS.starting_hanger = hangers_as["syndi_home"]
	NS.destinations = list(
		"Port Solars" = hangers_as["s_space_west"],
		"Starboard Solars" = hangers_as["s_space_east"],
		"Fore Side" = hangers_as["s_space_north"],
		"Fore Port Side" = hangers_as["s_space_north_west"],
		"Fore Starboard Side" = hangers_as["s_space_north_east"],
		"Aft Side" = hangers_as["s_space_south"],
		"Aft Port Side" = hangers_as["s_space_south_west"],
		"Aft Starboard Side" = hangers_as["s_space_south_east"]
		)

	NS.announcer = "NDV Icarus"
	NS.arrival_message = "Attention, Apollo, you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	NS.departure_message = "Your visitors are on their way out of the system, Apollo, burning delta-v like it's nothing. Good riddance."
	NS.warmup_time = 0
	NS.docking_controller_tag = "Nuke_Shuttle"
	shuttles["Mercenary"] = NS



	//Valen's shuttle - same layout as nuke and goes to the same locations
	var/datum/shuttle/multi_shuttle/VALS = new/datum/shuttle/multi_shuttle()
	VALS.template_path ="maps/templates/shuttles/valen_shuttle.dmm"
	VALS.destinations = list(
		"Port Solars" = hangers_as["s_space_west"],
		"Starboard Solars" = hangers_as["s_space_east"],
		"Fore Side" = hangers_as["s_space_north"],
		"Fore Port Side" = hangers_as["s_space_north_west"],
		"Fore Starboard Side" = hangers_as["s_space_north_east"],
		"Aft Side" = hangers_as["s_space_south"],
		"Aft Port Side" = hangers_as["s_space_south_west"],
		"Aft Starboard Side" = hangers_as["s_space_south_east"]
		)

	VALS.announcer = "NDV Icarus"
	VALS.arrival_message = "Attention, Apollo, you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	VALS.departure_message = "Your visitors are on their way out of the system Apollo. They are moving to fast for us to atempt an intercept."
	VALS.warmup_time = 0
	VALS.docking_controller_tag = "Valen's Shuttle"
	shuttles["Valans"] = VALS

/datum/shuttle_controller/proc/setup()
	var/datum/shuttle/shuttle
	for (var/shuttle_tag in shuttles)
		spawn(0)
			shuttle = shuttles[shuttle_tag]
			shuttle.init_templates()
	init_done = 1

//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/shuttle_controller/proc/setup_shuttle_docks()
	//We MUST wait for the shuttles to be ingame otherwise the docking controllers will not be found
	while(!init_done)
		sleep(50)
	var/datum/shuttle/shuttle
	var/datum/shuttle/ferry/multidock/multidock
	var/list/dock_controller_map = list()	//so we only have to iterate once through each list

	//multidock shuttles
	var/list/dock_controller_map_station = list()
	var/list/dock_controller_map_offsite = list()

	//We dont want to check the mutli_shuttle because it will (almost) only dock in space
	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		if(istype(shuttle, /datum/shuttle/multi_shuttle))
			continue
		if (shuttle.docking_controller_tag)
			dock_controller_map[shuttle.docking_controller_tag] = shuttle
		if (istype(shuttle, /datum/shuttle/ferry/multidock))
			multidock = shuttle
			dock_controller_map_station[multidock.docking_controller_tag_station] = multidock
			dock_controller_map_offsite[multidock.docking_controller_tag_offsite] = multidock

	//escape pod arming controllers
	var/datum/shuttle/ferry/escape_pod/pod
	var/list/pod_controller_map = list()
	for (var/datum/shuttle/ferry/escape_pod/P in emergency_shuttle.escape_pods)
		if (P.dock_target_station)
			pod_controller_map[P.dock_target_station] = P

	//search for the controllers, if we have one.
	if (dock_controller_map.len)
		for (var/obj/machinery/embedded_controller/radio/C in machines)	//only radio controllers are supported at the moment
			if (istype(C.program, /datum/computer/file/embedded_program/docking))
				if (C.id_tag in dock_controller_map)
					shuttle = dock_controller_map[C.id_tag]
					shuttle.docking_controller = C.program
					dock_controller_map -= C.id_tag

					//escape pods
					if(istype(C, /obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod) && istype(shuttle, /datum/shuttle/ferry/escape_pod))
						var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/EPC = C
						EPC.pod = shuttle

				if (C.id_tag in dock_controller_map_station)
					multidock = dock_controller_map_station[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_station = C.program
						dock_controller_map_station -= C.id_tag
				if (C.id_tag in dock_controller_map_offsite)
					multidock = dock_controller_map_offsite[C.id_tag]
					if (istype(multidock))
						multidock.docking_controller_offsite = C.program
						dock_controller_map_offsite -= C.id_tag

				//escape pods
				if (C.id_tag in pod_controller_map)
					pod = pod_controller_map[C.id_tag]
					if (istype(C.program, /datum/computer/file/embedded_program/docking/simple/escape_pod/))
						pod.arming_controller = C.program

	//sanity check
	if (dock_controller_map.len || dock_controller_map_station.len || dock_controller_map_offsite.len)
		var/dat = ""
		for (var/dock_tag in dock_controller_map + dock_controller_map_station + dock_controller_map_offsite)
			dat += "\"[dock_tag]\", "
		world << "<span class='alert'>\b warning: shuttles with docking tags [dat] could not find their controllers!</span>"

	//makes all shuttles docked to something at round start go into the docked state
	for (var/shuttle_tag in shuttles)
		shuttle = shuttles[shuttle_tag]
		shuttle.dock()
