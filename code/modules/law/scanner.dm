/obj/machinery/court_scanner
	name = "ID scanner"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "scanner_id"
	desc = "A scanner for IDs. Used in trials for registering a participant."

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	var/console_tag
	var/obj/machinery/computer/sentencing/console

/obj/machinery/court_scanner/New()
	..()

	spawn( 10 )
		if( console_tag )
			console = locate( console_tag )

/obj/machinery/court_scanner/attackby( obj/item/weapon/card/id/O as obj, user as mob)
	if( console && istype( O ))
		var/obj/item/weapon/card/id/C = O
		if( console.incident && C.mob )
			if( console.incident.isInTrial( C.mob ) )
				user << "<span class='alert'>That person already has a role in the trial! Clear them from the console first to change their role.</span>"
				return

			if( console.incident.criminal == C.mob ) // Wont ping if you accindetally click it after being verified
				return

			if( console.incident.criminal )
				user << "<span class='alert'>There is already a defendant! Clear them from the console to take their place.</span>"
			else
				console.incident.criminal = C.mob
				ping( "\The [src] pings, \"Defendant [C.mob] verified.\"" )
		else
			if( !console.incident )
				user << "<span class='alert'>Console has no active trial!</span>"
			else if( !C.mob )
				user << "<span class='alert'>ID is not tied to a NanoTrasen Employee!</span>"
		return

	..()

/obj/machinery/court_scanner/arbiter
	var/title

/obj/machinery/court_scanner/arbiter/attackby(obj/item/weapon/card/id/O as obj, user as mob)
	if( console && istype( O ))
		var/obj/item/weapon/card/id/C = O
		if( console.incident && C.mob )
			var/error = console.incident.addArbiter( C, title )
			if( !error )
				ping( "\The [src] pings, \"[title] [C.mob] verified.\"" )
			else
				user << "<span class='alert'>[error]</span>"
		else
			if( !console.incident )
				user << "<span class='alert'>Console has no active trial!</span>"
			else if( !C.mob )
				user << "<span class='alert'>ID is not tied to a NanoTrasen Employee!</span>"

		return

	..()

/obj/machinery/court_scanner/courtroom
	console_tag = "sentencing_courtroom"

/obj/machinery/court_scanner/arbiter/courtroom
	console_tag = "sentencing_courtroom"

/obj/machinery/court_scanner/arbiter/courtroom/chief_justice
	name = "Chief Justice ID scanner"
	title = "Chief Justice"

/obj/machinery/court_scanner/arbiter/courtroom/justice1
	name = "Justice #1 ID scanner"
	title = "Justice #1"

/obj/machinery/court_scanner/arbiter/courtroom/justice2
	name = "Justice #2 ID scanner"
	title = "Justice #2"

/obj/machinery/court_scanner/arbiter/courtroom/pros_attorney
	name = "Prosecuting Attorney ID scanner"
	title = "Prosecuting Attorney"

/obj/machinery/court_scanner/arbiter/courtroom/def_attorney
	name = "Defending Attorney ID scanner"
	title = "Defending Attorney"

/obj/machinery/court_scanner/arbiter/courtroom/witness
	name = "Witness ID scanner"
	title = "Witness"
