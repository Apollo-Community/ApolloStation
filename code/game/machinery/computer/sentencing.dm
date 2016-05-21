/obj/machinery/computer/sentencing
	name = "criminal sentencing console"
	desc = "Used to generate a criminal sentence."
	icon_state = "sentence"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = "/obj/item/weapon/circuitboard/sentencing"

	var/datum/crime_incident/incident
	var/menu_screen = "main_menu"

	var/datum/browser/menu = new( null, "crim_sentence", "Criminal Sentencing", 710, 725 )

/obj/machinery/computer/sentencing/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/sentencing/attackby(obj/item/O as obj, user as mob)
	if( istype( O, /obj/item/weapon/paper/form/incident ) && menu_screen == "import_incident" )
		usr.drop_item()
		O.loc = src

		if( import( O ))
			ping( "\The [src] pings, \"Successfully imported incident report!\"" )
			menu_screen = "incident_report"
		else
			buzz( "\The [src] buzzes, \"Could not import incident report.\"" )

		qdel( O )
	else if( istype( O, /obj/item/weapon/paper ) && menu_screen == "import_incident" )
		buzz( "\The [src] buzzes, \"This console only accepts authentic incident reports. Copies are invalid.\"" )

	..()

/obj/machinery/computer/sentencing/proc/import( var/obj/item/weapon/paper/form/incident/I )
	incident = null

	if( istype( I ) && I.incident )
		incident = I.incident

	return incident

/obj/machinery/computer/sentencing/ui_interact( mob/user as mob )
	. = ""

	switch( menu_screen )
		if( "import_incident" )
			. += import_incident()
		if( "incident_report" )
			. += incident_report()
		if( "low_severity" )
			. += add_charges()
		if( "med_severity" )
			. += add_charges()
		if( "high_severity" )
			. += add_charges()
		else
			. += main_menu()

	menu.set_user( user )
	menu.set_content( . )
	menu.open()

	onclose(user, "crim_sentence")

	return

/obj/machinery/computer/sentencing/proc/main_menu()
	. = "<center><h2>Welcome! Please select an option!</h2><br>"
	. += "<a href='?src=\ref[src];button=import_incident'>Import Incident</a>   <a href='?src=\ref[src];button=new_incident'>New Report</a></center>"

	return .

/obj/machinery/computer/sentencing/proc/import_incident()
	. = "<center><h2>Incident Import</h2><br>"
	. += "Insert an existing Securty Incident Report paper."

	. += "<br><hr>"
	. += "<a href='?src=\ref[src];button=change_menu;choice=main_menu'>Cancel</a></center>"

	return .

/obj/machinery/computer/sentencing/proc/incident_report()
	. = ""

	if( !istype( incident ))
		. += "There was an error loading the incident, please <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Try Again</a>"
		return .

	// Criminal and sentence
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th>Criminal:</th>"
	. += "<td><a href='?src=\ref[src];button=change_criminal;'>"
	if( incident.criminal )
		. += "[incident.criminal]"
	else
		. += "None"
	. += "</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Brig Sentence:</th>"
	. += "<td><a href='?src=\ref[src];button=change_brig;'>"
	if( incident.brig_sentence )
		if( incident.brig_sentence < PERMABRIG_SENTENCE )
			. += "[incident.brig_sentence] MINUTES"
		else
			. += "HOLDING UNTIL TRANSFER"
			. += "</a></td>"

			. += "</tr><tr>"

			. += "<th>Prison Sentence:</th>"
			. += "<td><a href='?src=\ref[src];button=change_prison;'>"
			if( incident.prison_sentence )
				if( incident.prison_sentence < PERMAPRISON_SENTENCE )
					. += "[incident.prison_sentence] DAYS"
				else
					. += "LIFE SENTENCE"
			else
				. += "None"
	else
		. += "None"
	. += "</a></td>"
	. += "</tr>"

	. += "</table>"

	. += "<br>"

	// Incident notes table
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th>Notes <a href='?src=\ref[src];button=add_notes'>Change</a></th>"
	. += "</tr>"
	. += "<tr>"
	. += "<td>[incident.notes]</td>"
	. += "</tr>"
	. += "</table>"

	. += "<br>"

	// Charges list
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th colspan='3'>Charges <a href='?src=\ref[src];button=change_menu;choice=low_severity'>Add</a></th>"
	. += "</tr>"
	for( var/datum/law/L in incident.charges )
		. += "<tr>"
		. += "<td><b>[L.name]</b></td>"
		. += "<td><i>[L.desc]</i></td>"
		. += "<td><a href='?src=\ref[src];button=remove_charge;law=\ref[L]'>Remove</a></td>"
		. += "</tr>"
	. += "</table>"

	. += "<br><hr>"
	. += "<center><a href='?src=\ref[src];button=print_encoded_form'>Print</a> <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Cancel</a></center>"

	return .

/obj/machinery/computer/sentencing/proc/add_charges()
	. = ""

	if( !istype( incident ))
		. += "There was an error loading the incident, please <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Try Again</a>"
		return .

	if( !istype( corp_regs ))
		. += "There was an error loading corporate regulations, please <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Try Again</a>"
		return .

	. += charges_header()
	. += "<hr>"
	switch( menu_screen )
		if( "low_severity" )
			. += low_severity()
		if( "med_severity" )
			. += med_severity()
		if( "high_severity" )
			. += high_severity()

	. += "<br><hr>"
	. += "<center><a href='?src=\ref[src];button=change_menu;choice=incident_report'>Return</a></center>"

/obj/machinery/computer/sentencing/proc/charges_header()
	. = "<center>"

	if( menu_screen == "low_severity" )
		. += "Low Severity"
	else
		. += "<a href='?src=\ref[src];button=change_menu;choice=low_severity'>Low Severity</a>"

	. += " - "

	if( menu_screen == "med_severity" )
		. += "Medium Severity"
	else
		. += "<a href='?src=\ref[src];button=change_menu;choice=med_severity'>Medium Severity</a>"

	. += " - "

	if( menu_screen == "high_severity" )
		. += "High Severity"
	else
		. += "<a href='?src=\ref[src];button=change_menu;choice=high_severity'>High Severity</a>"

	. += "</center>"

	return .

/obj/machinery/computer/sentencing/proc/low_severity()
	. = ""

	// Low severity
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th colspan='5'>Misdemeanors</th>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Name</th>"
	. += "<th>Description</th>"
	. += "<th>Brig Sentence</th>"
//	. += "<th>Fine</th>"
	. += "<th>Button</th>"
	. += "</tr>"

	for( var/datum/law/L in corp_regs.low_severity )
		. += "<tr>"
		. += "<td><b>[L.name]</b></td>"
		. += "<td><i>[L.desc]</i></td>"
		. += "<td>[L.min_brig_time] - [L.max_brig_time] minutes</td>"
//		. += "<td>$[L.min_fine] - $[L.max_fine]</td>"
		. += "<td><a href='?src=\ref[src];button=add_charge;law=\ref[L]'>Charge</a></td>"
		. += "</tr>"

	. += "</table>"

	return .

/obj/machinery/computer/sentencing/proc/med_severity()
	. = ""

	// Med severity
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th colspan='5'>Indictable Offences</th>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Name</th>"
	. += "<th>Description</th>"
	. += "<th>Brig Sentence</th>"
	. += "<th>Prison Sentence</th>"
//	. += "<th>Fine</th>"
	. += "<th>Button</th>"
	. += "</tr>"

	for( var/datum/law/L in corp_regs.med_severity )
		. += "<tr>"
		. += "<td><b>[L.name]</b></td>"
		. += "<td><i>[L.desc]</i></td>"
		. += "<td>[L.min_brig_time] - [L.max_brig_time] minutes</td>"
		. += "<td>[L.min_prison_time] - [L.max_prison_time] days</td>"
//		. += "<td>$[L.min_fine] - $[L.max_fine]</td>"
		. += "<td><a href='?src=\ref[src];button=add_charge;law=\ref[L]'>Charge</a></td>"
		. += "</tr>"

	. += "</table>"

	return .

/obj/machinery/computer/sentencing/proc/high_severity()
	. = ""

	// High severity
	. += "<table class='border'>"
	. += "<tr>"
	. += "<th colspan='5'>Capital Offences</th>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Name</th>"
	. += "<th>Description</th>"
	. += "<th>Brig Sentence</th>"
	. += "<th>Prison Sentence</th>"
	. += "<th>Button</th>"
	. += "</tr>"

	for( var/datum/law/L in corp_regs.high_severity )
		. += "<tr>"
		. += "<td><b>[L.name]</b></td>"
		. += "<td><i>[L.desc]</i></td>"
		. += "<td>[L.min_brig_time] - [L.max_brig_time] minutes</td>"
		. += "<td>[L.min_prison_time] - [L.max_prison_time] days</td>"
		. += "<td><a href='?src=\ref[src];button=add_charge;law=\ref[L]'>Charge</a></td>"
		. += "</tr>"

	. += "</table>"

	return .

/obj/machinery/computer/sentencing/Topic(href, href_list)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	usr.set_machine(src)

	switch(href_list["button"])
		if( "import_incident" )
			menu_screen = "import_incident"
		if( "new_incident" )
			incident = new()

			menu_screen = "incident_report"
		if( "change_menu" )
			menu_screen = href_list["choice"]
		if( "change_criminal" )
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if( istype( C ))
				if( incident && C.mob )
					incident.criminal = C.mob
					ping( "\The [src] pings, \"Criminal [C.mob] verified.\"" )
			else
				ping( "\The [src] buzzes, \"Criminal cleared.\"" )
				incident.criminal = null
		if( "change_brig" )
			if( !incident )
				return

			var/number = input( usr, "Enter a number between [incident.getMinBrigSentence()] and [incident.getMaxBrigSentence()] minutes", "Brig Sentence", 0) as num
			if( number < incident.getMinBrigSentence() )
				buzz( "\The [src] buzzes, \"The entered sentence was less than the minimum sentence!\"" )
			else if( number > incident.getMaxBrigSentence() )
				buzz( "\The [src] buzzes, \"The entered sentence was greater than the maximum sentence!\"" )
			else
				incident.brig_sentence = number

		if( "change_prison" )
			if( !incident )
				return

			var/number = input( usr, "Enter a number between [incident.getMinPrisonSentence()] and [incident.getMaxPrisonSentence()] days", "Prison Sentence", 0) as num
			if( number < incident.getMinPrisonSentence() )
				buzz( "\The [src] buzzes, \"The entered sentence was less than the minimum sentence!\"" )
			else if( number > incident.getMaxPrisonSentence() )
				buzz( "\The [src] buzzes, \"The entered sentence was greater than the maximum sentence!\"" )
			else
				incident.prison_sentence = number
		if( "print_encoded_form" )
			var/obj/item/weapon/paper/form/incident/I = new /obj/item/weapon/paper/form/incident
			I.incident = incident
			I.name = "Encoded Incident Report"
			print( I )
			incident = null
			menu_screen = "main_menu"
		if( "add_charge" )
			incident.charges += locate( href_list["law"] )
			incident.setMinSentence()
		if( "remove_charge" )
			incident.charges -= locate( href_list["law"] )
			incident.setMinSentence()

		if( "add_notes" )
			if( !incident )
				return

			var/incident_notes  = sanitize( input( usr,"Describe the incident here:","Incident Report", html_decode( incident.notes )) as message, MAX_PAPER_MESSAGE_LEN, extra = 0)
			if( incident_notes != null )
				incident.notes = incident_notes

	add_fingerprint(usr)
	updateUsrDialog()
