/obj/machinery/computer/crew
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked = list(  )
	light_color = COMPUTER_BLUE

/obj/machinery/computer/crew/New()
	tracked = list()
	..()


/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER


/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if (src.z in  overmap.admin_levels)
		usr << "<span class='alert'><b>Unable to establish a connection</b>: </span><span class='black'>You're too far away from the station!</span>"
		return 0
	if( href_list["close"] )
		var/mob/user = usr
		var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
		usr.unset_machine()
		ui.close()
		return 0
	if(href_list["update"])
		src.updateDialog()
		return 1

/obj/machinery/computer/crew/interact(mob/user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	src.scan()

	var/data[0]
	var/list/crewmembers = list()

	for(var/obj/item/clothing/under/C in src.tracked)

		var/turf/pos = get_turf(C)

		if((C) && (C.has_sensor) && (pos) && (pos.z == src.z) && (C.sensor_mode != SUIT_SENSOR_OFF))
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc
				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1)

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
				crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
				crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")

				if(C.sensor_mode >= SUIT_SENSOR_BINARY)
					crewmemberData["dead"] = H.stat > 1

				if(C.sensor_mode >= SUIT_SENSOR_VITAL)
					crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
					crewmemberData["tox"] = round(H.getToxLoss(), 1)
					crewmemberData["fire"] = round(H.getFireLoss(), 1)
					crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
					var/area/A = get_area(H)
					crewmemberData["area"] = sanitize(A.name)
					crewmemberData["x"] = pos.x
					crewmemberData["y"] = pos.y

				crewmembers[++crewmembers.len] = crewmemberData

	//crewmembers = sortByKey(crewmembers, "name")

	data["crewmembers"] = crewmembers

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)


/obj/machinery/computer/crew/proc/scan()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/C = H.w_uniform
			if (C.has_sensor)
				tracked |= C
	return 1
