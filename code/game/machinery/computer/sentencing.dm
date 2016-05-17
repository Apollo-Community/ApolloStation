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
		if( "main_menu" )
			. += main_menu()
		if( "import_incident" )
			. += import_incident()
		if( "incident_report" )
			. += incident_report()

	menu.set_user( user )
	menu.set_content( . )
	menu.open()

	onclose(user, "crim_sentence")

	return

/obj/machinery/computer/sentencing/proc/main_menu()
	. = "<center><h2>Welcome! Please select an option!</h2><br>"
	. += "<a href='?src=\ref[src];button=import_incident'>Import Report</a>   <a href='?src=\ref[src];button=new_incident'>New Report</a></center>"

	return .

/obj/machinery/computer/sentencing/proc/import_incident()
	. = "<center><h2>Incident Import</h2><br>"
	. += "Insert the encoded incident report paper or <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Cancel</a></center>"

	return .

/obj/machinery/computer/sentencing/proc/incident_report()
	if( !incident )
		. += "There was an error loading the report, please <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Try Again</a>"
		return .

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

	. += "<table class='border'>"
	. += "<tr>"
	. += "<th colspan='3'><a href='?src=\ref[src];button=add_charges;'>Add Charges</a></th>"
	. += "</tr>"
	. += "</table>"

	. += "<br><br>"
	. += "<center><a href='?src=\ref[src];button=print_encoded_form'>Print</a> <a href='?src=\ref[src];button=change_menu;choice=main_menu'>Cancel</a></center>"

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
		if( "add_charges" )
			buzz( "LOL" )

	add_fingerprint(usr)
	updateUsrDialog()
