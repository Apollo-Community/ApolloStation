/*
How opening a bluespace gate works
 1. You select your destination on the Bluespace Beacon Console
 2. That sends a signal to the beacon, which sends a signal to its linked inducers
 3. The inducers activate and begin to charge the beacon
 4. After the beacon reaches max charge, it creates a Bluespace Gate, with the destination
 	as set by the Bluespace Beacon Console
 5. The Bluespace Gate takes everything inside of it to the destination, including turfs
*/

var/global/list/bluespace_beacons = list()

// ========= BLUESPACE BEACON ============

/obj/machinery/gate_beacon
	name = "bluespace beacon"
	desc = "A beacon used to open gates into bluespace."
	icon = 'icons/obj/bluespace_gate.dmi'
	icon_state = "beacon0"
	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1
	l_color = "#142933"
	luminosity = 0
	var/functional = 1
	var/charge = 0 // Used for charging a bluespace gate
	var/last_charge = 0 // What the charge was last tick
	var/charge_decay = 15 // How much charge the beacon loses per tick
	var/max_charge = 1000 // Used for charging a bluespace gate
	var/ticks_since_announce = 0
	var/obj/machinery/gate_beacon/exit = null
	var/obj/effect/map/sector = null
	var/list/inducers = list()

/obj/machinery/gate_beacon/New()
	src.ping("[src] states, \"Initializing...\"")
	spawn(20)
		sector = map_sectors["[z]"]
		if( !sector )
			functional = 0
			src.ping("[src] states, \"ERROR: Critical error with the bluespace network!\"")
			return

		if( name == "bluespace beacon" )
			var/hash = "[pick( alphabet_uppercase )][pick( alphabet_uppercase )][rand(0, 9)]"
			name = "Bluespace Beacon [hash]-[sector.x][sector.y]"

		bluespace_beacons["[name]"] = src


	..()

	luminosity = 2
	l_color = "#142933"

/obj/machinery/gate_beacon/Del()
	bluespace_beacons["[name]"] = null
	..()

/obj/machinery/gate_beacon/update_icon()
	if( functional )
		if( charge > 0 )
			icon_state = "beacon1"
			SetLuminosity( 2 )
			return
	icon_state = "beacon0"
	SetLuminosity( 0 )

/obj/machinery/gate_beacon/process()
	if( charge >= max_charge )
		open_gate( exit )
	if( charge >= 25 )
		if( ticks_since_announce > 50 )
			ticks_since_announce = 0
			var/message = null
			if( charge > last_charge )
				message = "[src] states, \"Charge raising. Charge at [round(charge/max_charge)]%\""
			else if( charge <= last_charge )
				message = "[src] states, \"Charge falling! Charge at [round(charge/max_charge)]%\""
			ping( message )
		else
			ticks_since_announce++

	last_charge = charge
	charge -= charge_decay
	if( charge < 0 )
		charge = 0

/obj/machinery/gate_beacon/proc/open_gate()
	if( src == exit )
		src.ping("[src] states, \"ERROR: Critical error with the bluespace network!\"")
		return
	if( !functional )
		src.ping("[src] states, \"ERROR: Failed to interface with bluespace network!\"")
		return
	if( !exit.functional )
		src.ping("[src] states, \"ERROR: Failed to interface with destination beacon!\"")
		return

	src.ping("[src] states, \"Opening bluespace gate. Prepare to embark.\"")
	exit.ping("[exit] states, \"Offsite activation. Please clear the area.\"")

	new /obj/machinery/singularity/bluespace_gate(src.loc, exit)

	deactivate()

/obj/machinery/gate_beacon/proc/charge( var/charge_rate = 0 )
	charge += charge_rate

/obj/machinery/gate_beacon/proc/activate( var/obj/machinery/gate_beacon/dest = null )
	exit = dest

	if( inducers.len < 1 )
		ping("[src] states, \"ERROR: No bluespace inducers nearby!\"")
	for( var/obj/machinery/power/bluespace_inducer/inducer in inducers )
		inducer.activate( src )

	spawn( 30 )
		update_icon()

/obj/machinery/gate_beacon/proc/deactivate()
	for( var/obj/machinery/power/bluespace_inducer/inducer in inducers )
		inducer.deactivate()

	charge = 0
	update_icon()

// ========= BLUESPACE GATE CONTROL CONSOLE =========

/obj/machinery/computer/gate_beacon_console
	name = "Bluespace Beacon Console"
	desc = "A console used to set the destination for bluespace gates."
	icon = 'icons/obj/machines/launch_computer.dmi'
	icon_state = "launch0"
	use_power = 0
	var/obj/machinery/gate_beacon/beacon = null
	var/functional = 0

/obj/machinery/computer/gate_beacon_console/New()
	find_beacon()

	..()

/obj/machinery/computer/gate_beacon_console/update_icon()
	if( functional )
		if( beacon )
			if( beacon.charge > 0 )
				icon_state = "launch2"
		else
			icon_state = "launch"
	else
		icon_state = "launch0"

/obj/machinery/computer/gate_beacon_console/proc/find_beacon()
	for( beacon in orange( 7, src ))
		break
	if( beacon )
		functional = 1
		update_icon()
		return 1
	else
		return 0

/obj/machinery/computer/gate_beacon_console/proc/gate_prompt( var/mob/user = usr )
	if( !beacon )
		if( !find_beacon() )
			ping("[src] states, \"ERROR: Cannot find nearby bluespace beacon!\"")

	var/obj/machinery/gate_beacon/destination

	var/list/bluespace_beacons_dest = bluespace_beacons
	bluespace_beacons_dest.Remove( beacon )

	destination = input( user, "Where would you like to open a bluespace gate to?", "Destination", destination ) in bluespace_beacons_dest

	if( destination )
		beacon.activate( bluespace_beacons[destination] )
	else
		ping("[src] states, \"ERROR: No valid destination chosen!\"")

	spawn( 30 )
		update_icon()