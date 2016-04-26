var/global/datum/hanger_controller/hanger_controller

datum/hanger_controller
	var/list/hangers
	var/list/hangers_as
	var/list/blue_space_hangers
	var/list/blue_space_hangers_as
	var/list/start_hangers_as
	var/list/start_hangers

datum/hanger_controller/New()
	hangers = new /list()
	hangers_as = new /list()
	blue_space_hangers = new /list()
	blue_space_hangers_as = new /list()
	start_hangers_as = new /list()
	start_hangers	= new /list()
	var/datum/hanger/H

	//Hangers:
	//Escape pod hangers on station
	H = new /datum/hanger()
	H.tag = "Station_E1_Hanger"
	H.beacon_tag = "s_hanger_e1"
	H.dimx = 3
	H.dimy = 5
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "Station_E2_Hanger"
	H.beacon_tag = "s_hanger_e2"
	H.dimx = 3
	H.dimy = 5
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "Station_E3_Hanger"
	H.beacon_tag = "s_hanger_e3"
	H.dimx = 5
	H.dimy = 3
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "Station_E5_Hanger"
	H.beacon_tag = "s_hanger_e5"
	H.dimx = 5
	H.dimy = 3
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H


	//Escape pod hangers at resque ship
	H = new /datum/hanger()
	H.tag = "CentCom_E1_Hanger"
	H.beacon_tag = "c_hanger_e1"
	H.dimx = 3
	H.dimy = 5
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "CentCom_E2_Hanger"
	H.beacon_tag = "c_hanger_e2"
	H.dimx = 3
	H.dimy = 5
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "CentCom_E3_Hanger"
	H.beacon_tag = "c_hanger_e3"
	H.dimx = 5
	H.dimy = 3
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "CentCom_E5_Hanger"
	H.beacon_tag = "c_hanger_e5"
	H.dimx = 5
	H.dimy = 3
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Main station hangers
	//Left station hanger
	H = new /datum/hanger()
	H.tag = "Station_L_Hanger"
	H.beacon_tag = "s_hanger_l"
	H.dimx = 7
	H.dimy = 11
	H.exterior = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Center station hanger
	H = new /datum/hanger()
	H.tag = "Station_C_Hanger"
	H.beacon_tag = "s_hanger_c"
	H.dimx = 11
	H.dimy = 5
	H.exterior = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Center right hanger
	H = new /datum/hanger()
	H.tag = "Station_R_Hanger"
	H.beacon_tag = "s_hanger_r"
	H.dimx = 7
	H.dimy = 11
	H.exterior = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Center extended (emergency shuttle) hanger
	//This is not a square hanger so give a docking area
	H = new /datum/hanger()
	H.tag = "Station_ES_Hanger"
	H.beacon_tag = "s_hanger_ex"
	H.hanger_area = locate(/area/podbay/hangar/s_hanger_e)
	H.exterior = 1
	H.square = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//CentCom hangers
	//Left centcom hanger
	H = new /datum/hanger()
	H.tag = "CentCom_L_Hanger"
	H.beacon_tag = "c_hanger_l"
	H.dimx = 7
	H.dimy = 11
	H.exterior = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//right centcom hanger
	H = new /datum/hanger()
	H.tag = "CentCom_R_Hanger"
	H.beacon_tag = "c_hanger_r"
	H.dimx = 7
	H.dimy = 11
	H.exterior = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//right centcom hanger
	H = new /datum/hanger()
	H.tag = "CentCom_ES_Hanger"
	H.beacon_tag = "c_hanger_e"
	H.exterior = 1
	H.hanger_area = locate(/area/shuttle/escape/centcom)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Relief Frigate hanger
	H = new /datum/hanger()
	H.tag = "Frigate_Hanger"
	H.beacon_tag = "f_hanger"
	H.exterior = 0
	H.dimx = 11
	H.dimy = 5
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger N
	H = new /datum/hanger()
	H.tag = "Space_N_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/north)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger N-E
	H = new /datum/hanger()
	H.tag = "Space_NE_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/northeast)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger E
	H = new /datum/hanger()
	H.tag = "Space_E_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/east)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger S-E
	H = new /datum/hanger()
	H.tag = "Space_SE_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/southeast)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger S
	H = new /datum/hanger()
	H.tag = "Space_S_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/south)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger SW
	H = new /datum/hanger()
	H.tag = "Space_SW_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/southwest)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger W
	H = new /datum/hanger()
	H.tag = "Space_W_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/west)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Space hanger N-W
	H = new /datum/hanger()
	H.tag = "Space_NW_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/hanger/northwest)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Home hanger for the nuke ops syndicate shuttle
	H = new /datum/hanger()
	H.tag = "Syndi_Home_Hanger"
	H.beacon_tag = "sy_home"
	H.hanger_area = locate(/area/syndicate_mothership/offsite_hanger)
	H.exterior = 1
	H.square = 0
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	//Generating bluespace hangers for long jumps
	for(var/i=1, i <= 7, i++)
		H = new /datum/hanger()
		H.tag = "Blue_Space_[i]"
		H.exterior = 1
		H.hanger_area = locate(text2path("/area/space/bluespace/hanger_[i]"))
		blue_space_hangers_as[H.tag] = H
		blue_space_hangers += H

	//Generating CC starting hangers for generic ships
	for(var/i=1, i <= 10, i++)
		H = new /datum/hanger()
		H.tag = "Start_Hanger_[i]"
		H.exterior = 1
		H.hanger_area = locate(text2path("/area/space/s_hanger_[i]"))
		start_hangers_as[H.tag] = H
		start_hangers += H

	init_hangers()
/datum/hanger_controller/proc/remove_space_beacons()
	var/obj/locObj
	for(var/datum/hanger/H in hangers)
		if(!H.exterior)
			continue
		locObj = locate(H.loc.x_pos, H.loc.y_pos, H.loc.z_pos)
		qdel(locObj)

/datum/hanger_controller/proc/init_hangers()
	for(var/datum/hanger/H in hangers + blue_space_hangers + start_hangers)
		H.init_hanger()
		error("Hanger [H.tag] created at [H.hanger_area] has [H.hanger_area_turfs.len] turfs")

//Need to make this
/datum/hanger_controller/proc/get_free_interim_hanger(var/datum/shuttle/S)
	for(var/datum/hanger/H in blue_space_hangers)
		if(H.can_land_at(S))
			return H
	return null

/datum/hanger_controller/proc/ger_free_starting_hanger(var/datum/shuttle/S)
	for(var/datum/hanger/H in start_hangers)
		if(H.can_land_at(S))
			return H
	return null