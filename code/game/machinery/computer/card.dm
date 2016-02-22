//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/card
	name = "\improper promotions console"
	desc = "Terminal for handling NanoTrasen employee promotions. Can also modify ID access."
	icon_state = "id"
	req_access = list(access_change_ids)
	circuit = "/obj/item/weapon/circuitboard/card"
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/modify = null
	var/mode = 0.0
	var/printing = null

	var/list/due_papers = list() // The promotion / demotion papers that the machine is still expecting

	light_color = COMPUTER_BLUE

// This return true if the modify card is lower rank than the scan card
/obj/machinery/computer/card/proc/modifyingSubordinate()
	var/datum/job/subordinate = job_master.GetJob( modify.assignment )
	var/datum/job/superior = job_master.GetJob( scan.assignment )

	if( superior && subordinate && ( superior.rank_succesion_level > subordinate.rank_succesion_level ))
		return 1
	return 0

/obj/machinery/computer/card/proc/is_authenticated()
	return scan ? check_access(scan) : 0

/obj/machinery/computer/card/proc/get_target_rank()
	if( !modify || !modify.assignment )
		return "Unassigned"

	return modify.assignment

/obj/machinery/computer/card/proc/format_jobs(list/jobs)
	var/list/formatted = list()
	for(var/job in jobs)
		formatted.Add(list(list(
			"display_name" = replacetext(job, " ", "&nbsp"),
			"job" = job)))

	return formatted

/obj/machinery/computer/card/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying)	return

	if(scan)
		usr << "You remove \the [scan] from \the [src]."
		scan.loc = get_turf(src)
		if(!usr.get_active_hand() && istype(usr,/mob/living/carbon/human))
			usr.put_in_hands(scan)
		scan = null

		if( modify )
			modify.loc = get_turf(src)
			if(!usr.get_active_hand() && istype(usr,/mob/living/carbon/human))
				usr.put_in_hands(modify)
			modify = null
	else if(modify)
		usr << "You remove \the [modify] from \the [src]."
		modify.loc = get_turf(src)
		if(!usr.get_active_hand() && istype(usr,/mob/living/carbon/human))
			usr.put_in_hands(modify)
		modify = null
	else
		usr << "There is nothing to remove from the console."
	return

/obj/machinery/computer/card/attackby( obj/O, mob/user)
	var/obj/item/weapon/paper/form/F = O
	if( F in due_papers )
		if( F.isFilledOut() )
			var/datum/character/C = due_papers[F]

			if( istype( O, /obj/item/weapon/paper/form/command_recommendation ))
				ping( "\The [src] pings, \"[C.name] has been recommended for additional command positions!\"" )
				C.addRecordNote( "general", F.info, "Command Recommendation" )
				var/obj/item/rcvdcopy

				rcvdcopy = copy(F)
				rcvdcopy.loc = null //hopefully this shouldn't cause trouble
				adminfaxes += rcvdcopy

				src.message_admins( user, "CENTCOMM FAX", rcvdcopy, "#006100" )
			else if( istype( O, /obj/item/weapon/paper/form/job ))
				var/obj/item/weapon/paper/form/job/J = O
				var/datum/job/job_datum
				if( istype( J, /obj/item/weapon/paper/form/job/induct ))
					C.SetDepartment( job_master.GetDepartmentByName( J.job ))
					job_datum = C.department.getLowestPosition()
				else if( istype( J, /obj/item/weapon/paper/form/job/termination ))
					C.LoadDepartment( CIVILIAN )
					job_datum = job_master.GetJob( "Assistant" )
				else if( istype( J, /obj/item/weapon/paper/form/job/promotion ))
					C.AddJob( J.job )
					job_datum = job_master.GetJob( J.job )
				else if( istype( J, /obj/item/weapon/paper/form/job/demotion ))
					C.RemoveJob( J.job )
					job_datum = C.department.getLowestPosition()
				else
					return

				if( !istype( job_datum ))
					return

				modify.access = job_datum.get_access()
				modify.assignment = job_datum.title
				modify.rank = job_datum.title

				modify.generateName()
				callHook("reassign_employee", list(modify))

				ping( "\The [src] pings, \"[C.name] has been [J.job_verb] [J.job]!\"" )
				C.addRecordNote( "general", J.info, "[capitalize( J.job_verb )] [J.job]" )

			due_papers -= F
			qdel( F )
			ui_interact(user)
			return
		else
			buzz( "\The [src] buzzes, \"This form was improperly filled out. Please try again.\"" )

			due_papers -= F
			qdel( F )
			return

	if( !istype( O, /obj/item/weapon/card/id ))
		return ..()

	var/obj/item/weapon/card/id/id_card = O

	if(!scan && access_change_ids in id_card.access)
		user.drop_item()
		id_card.loc = src
		scan = id_card
	else if(!modify)
		user.drop_item()
		id_card.loc = src
		modify = id_card

	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/card/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/card/attack_hand(mob/user as mob)
	if(..()) return
	if(stat & (NOPOWER|BROKEN)) return
	ui_interact(user)

/obj/machinery/computer/card/proc/department_name( var/obj/item/weapon/card/id/C )
	if( !istype( C ))
		return

	if( !C.character )
		return

	return C.character.department.name

/obj/machinery/computer/card/proc/is_inducted()
	if( !modify || !scan )
		return 0

	if( is_centcom() )
		return 1

	var/scan_department = department_name( scan )
	var/modify_department = department_name( modify )

	if( scan_department && modify_department && scan_department == modify_department )
		return 1
	return 0

/obj/machinery/computer/card/proc/can_induct()
	var/scan_department = department_name( scan )
	var/modify_department = department_name( modify )
	if( !scan_department || !modify_department )
		return 0

	if( is_centcom() )
		return 1

	if( modify_department == "Civilian" )
		return 1

	return 0

/obj/machinery/computer/card/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["mode"] = mode
	data["printing"] = printing
	data["manifest"] = data_core ? data_core.get_manifest(0) : null
	data["target_name"] = modify ? modify.name : "-----"
	data["target_owner"] = modify && modify.registered_name ? modify.registered_name : "-----"
	data["target_rank"] = get_target_rank()
	data["scan_name"] = scan ? scan.name : "-----"
	data["authenticated"] = is_authenticated()
	data["has_modify"] = !!modify
	data["inducted"] = is_inducted()
	data["can_induct"] = can_induct()
	data["account_number"] = modify ? modify.associated_account_number : null
	data["centcom_access"] = is_centcom()
	if( is_centcom() )
		data["modify_department_name"] = "CentComm"
	else
		data["modify_department_name"] = department_name( modify )
	data["all_centcom_access"] = null
	data["regions"] = null

	var/list/locked_jobs = list()
	var/list/unlocked_jobs = list()

	if( modify && modify.character && scan && scan.character && scan.character.department )
		var/datum/department/D = scan.character.department
		if( is_centcom() )
			locked_jobs = modify.character.getAllPromotablePositions( COMMAND_SUCCESSION_LEVEL+1 )
			unlocked_jobs = modify.character.getAllDemotablePositions( COMMAND_SUCCESSION_LEVEL+1 )
		else
			unlocked_jobs = D.getPromotablePositionNames() & modify.character.roles

			locked_jobs = D.getPromotablePositionNames()
			locked_jobs.Remove( unlocked_jobs )

	data["locked_jobs"] = format_jobs(locked_jobs)
	data["unlocked_jobs"] = format_jobs(unlocked_jobs)

	if (modify)
		var/list/regions = list()
		for(var/datum/department/D in job_master.departments)
			var/list/accesses = list()
			for(var/access in scan.access)
				if(( access in D.region_access ) && get_access_desc(access))
					accesses.Add(list(list(
						"desc" = replacetext(get_access_desc(access), " ", "&nbsp"),
						"ref" = access,
						"allowed" = (access in modify.access) ? 1 : 0)))

			if( accesses && accesses.len && D.name != "Synthetic" )
				regions.Add(list(list(
					"name" = D.name,
					"accesses" = accesses)))

		data["regions"] = regions

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", src.name, 600, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["choice"])
		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				if(ishuman(usr))
					modify.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					modify = I

		if ("scan")
			if (scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null

				if( modify )
					modify.loc = loc // ejecting the authorization card ejects the modified card
					modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					scan = I

		if("access")
			if(href_list["allowed"])
				if(is_authenticated())
					if( !modifyingSubordinate() )
						buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
						return

					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (is_centcom() ? get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(!access_allowed)
							modify.access += access_type

		if ("assign")
			if( is_authenticated() && modify && modifyingSubordinate() )
				if( !modifyingSubordinate() )
					buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
					return

				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = sanitize(input("Enter a custom job assignment.","Assignment"), 45)
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t && modify)
						modify.assignment = temp_t
				else
					var/list/access = list()
					if(is_centcom())
						access = get_centcom_access(t1)
					else
						var/datum/job/jobdatum
						for(var/jobtype in typesof(/datum/job))
							var/datum/job/J = new jobtype
							if(ckey(J.title) == ckey(t1))
								jobdatum = J
								break
						if(!jobdatum)
							usr << "<span class='alert'>No log exists for this job: [t1]</span>"
							return

						access = jobdatum.get_access()

					modify.access = access
					modify.assignment = t1
					modify.rank = t1

				callHook("reassign_employee", list(modify))

		if ("reg")
			if (is_authenticated())
				if( !modifyingSubordinate() )
					buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
					return

				var/t2 = modify
				if ((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/temp_name = sanitizeName(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						buzz( "[src] buzzes rudely." )
			nanomanager.update_uis(src)

		if ("account")
			if (is_authenticated())
				if( !modifyingSubordinate() )
					buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
					return

				var/t2 = modify
				if ((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/account_num = text2num(href_list["account"])
					modify.associated_account_number = account_num
			nanomanager.update_uis(src)

		if ("mode")
			mode = text2num(href_list["mode_target"])

		if ("print")
			if (!printing)
				printing = 1
				spawn(50)
					printing = null
					nanomanager.update_uis(src)

					var/obj/item/weapon/paper/P = new()
					if (mode)
						P.name = text("crew manifest ([])", worldtime2text())
						P.info = {"<h4>Crew Manifest</h4>
							<br>
							[data_core ? data_core.get_manifest(0) : ""]
						"}
					else if (modify)
						P.name = "access report"
						P.info = {"<h4>Access Report</h4>
							<u>Prepared By:</u> [scan.registered_name ? scan.registered_name : "Unknown"]<br>
							<u>For:</u> [modify.registered_name ? modify.registered_name : "Unregistered"]<br>
							<hr>
							<u>Assignment:</u> [modify.assignment]<br>
							<u>Account Number:</u> #[modify.associated_account_number]<br>
							<u>Blood Type:</u> [modify.blood_type]<br><br>
							<u>Access:</u><br>
						"}

						for(var/A in modify.access)
							P.info += "  [get_access_desc(A)]"
					print( P )
		if ("terminate")
/*			if (is_authenticated() && is_centcom())
				if( !modifyingSubordinate() )
					buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )

				ping( "\The [src] pings, \"[modify.registered_name] has been fired from NanoTrasen.\"")

				modify.assignment = "Terminated"
				modify.access = list()

				if( modify.character )
					modify.character.LoadDepartment( CIVILIAN )

				callHook("terminate_employee", list(modify))
			else*/
			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
				return

			var/list/names = list( scan.registered_name )

			var/obj/item/weapon/paper/form/job/termination/P = new( print_date( universe.date ), department_name( modify ), modify.registered_name)
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 45 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete.\"" )

		if ("induct")
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !scan.character.department )
				buzz("\The [src] buzzes, \"Authorized card has no active department!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!" )
				return

			var/list/names = list( modify.registered_name, scan.registered_name )

			var/obj/item/weapon/paper/form/job/induct/P = new( print_date( universe.date ), department_name( scan ))
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 45 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete.\"" )

		if ("change_role")
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!" )
				return

			var/datum/department/J = input(usr, "Choose the department to transfer to:", "Department Transfer")  as null|anything in modify.character.roles

			var/datum/job/job_datum = job_master.GetJob( J )
			if( !istype( job_datum ))
				return

			modify.access = job_datum.get_access()
			modify.assignment = job_datum.title
			modify.rank = job_datum.title

			modify.generateName()
			callHook("reassign_employee", list(modify))
			ping( "\The [src] pings, \"[modify.registered_name]'s role has been changed to [modify.rank].\"" )

		if ("transfer")
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !scan.character.department )
				buzz("\The [src] buzzes, \"Authorized card has no active department!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!" )
				return

			var/datum/department/D = input(usr, "Choose the department to transfer to:", "Department Transfer")  as null|anything in job_master.departments

			var/list/names = list( modify.registered_name, scan.registered_name )

			var/obj/item/weapon/paper/form/job/induct/P = new( print_date( universe.date ), D.name )
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 45 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete.\"" )

		if( "promote" )
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!" )
				return

			var/job_name = href_list["promote_role"]

			var/list/names = list( modify.registered_name, scan.registered_name )

			var/obj/item/weapon/paper/form/job/promotion/P = new( print_date( universe.date ), job_name, department_name( modify ))
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 45 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete.\"" )

		if( "recommend" )
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			var/list/names = list( scan.registered_name )

			var/obj/item/weapon/paper/form/command_recommendation/P = new( print_date( universe.date ), modify.registered_name )
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 45 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete.\"" )

		if( "demote" )
			if( !scan.character )
				buzz("\The [src] buzzes, \"Authorized card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modify.character )
				buzz("\The [src] buzzes, \"Modification card is not tied to a NanoTrasen Employee!\"")
				return

			if( !modifyingSubordinate() )
				buzz( "\The [src] buzzes, \"Not authorized to modify this card!\"" )
				return

			var/job_name = href_list["demote_role"]

			var/list/names = list( scan.registered_name )

			var/obj/item/weapon/paper/form/job/demotion/P = new( print_date( universe.date ), job_name, modify.registered_name, department_name( modify ))
			P.required_signatures = names
			due_papers[P] = modify.character
			print( P )
			spawn( 40 )
				ping( "\The [src] pings, \"Please fill out this form and return it to this console when complete." )
	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")

	return 1

/obj/machinery/computer/card/proc/is_centcom()
	if( scan && ( access_cent_captain in scan.access ))
		return 1
	return 0

/obj/machinery/computer/card/proc/message_admins(var/mob/sender, var/faxname, var/obj/item/sent, font_colour="#006100")
	var/msg = "<span class='notice'><b><font color='[font_colour]'>[faxname]: </font>[key_name(sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) </b>: Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a></span>"
	log_admin(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			C << msg

/obj/machinery/computer/card/centcom
	name = "\improper CentCom promotions console"
	circuit = "/obj/item/weapon/circuitboard/card/centcom"
	req_access = list( access_cent_captain )

/obj/machinery/computer/card/centcom/is_centcom()
	return 1

/obj/machinery/computer/card/proc/copy(var/obj/item/weapon/paper/copy)
	var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (loc)

	c.info = "<font color = #101010>"

	var/copied = html_decode(copy.info)
	copied = replacetext(copied, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
	copied = replacetext(copied, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
	c.info += copied
	c.info += "</font>"
	c.name = copy.name // -- Doohl
	c.fields = copy.fields
	c.stamps = copy.stamps
	c.stamped = copy.stamped
	c.ico = copy.ico
	c.offset_x = copy.offset_x
	c.offset_y = copy.offset_y
	var/list/temp_overlays = copy.overlays       //Iterates through stamps
	var/image/img                                //and puts a matching
	for (var/j = 1, j <= temp_overlays.len, j++) //gray overlay onto the copy
		if (findtext(copy.ico[j], "cap") || findtext(copy.ico[j], "cent"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
		else if (findtext(copy.ico[j], "deny"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
		else
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
		img.pixel_x = copy.offset_x[j]
		img.pixel_y = copy.offset_y[j]
		c.overlays += img
	c.updateinfolinks()
	return c
