var/global/datum/hanger_controller/hanger_controller

datum/hanger_controller
	var/list/hangers
	var/list/hangers_as

datum/hanger_controller/New()
	hangers = new /list()
	hangers_as = new /list()
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

	//From here on down are "event and costum" shuttle/hanger origins
	H = new /datum/hanger()
	H.tag = "Vox_Home_Hanger"
	H.exterior = 1
	H.hanger_area = locate(/area/shuttle/vox/station)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H

	H = new /datum/hanger()
	H.tag = "Syndi_Home_Hanger"
	H.exterior = 0
	H.hanger_area = locate(/area/syndicate_mothership/offsite_hanger)
	hangers_as += H.tag
	hangers_as[H.tag] = H
	hangers += H


	//Remove the space hanager beacons because my drawing skills are not for mortal eyes to see
	init_hangers()
/datum/hanger_controller/proc/remove_space_beacons()
	var/obj/locObj
	for(var/datum/hanger/H in hangers)
		if(!H.exterior)
			continue
		locObj = locate(H.loc.x_pos, H.loc.y_pos, H.loc.z_pos)
		qdel(locObj)

/datum/hanger_controller/proc/init_hangers()
	for(var/datum/hanger/H in hangers)
		error("Hanger [H.tag] is setting itself up")
		H.init_hanger()