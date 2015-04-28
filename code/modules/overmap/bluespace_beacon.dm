var/global/list/bluespace_beacons = list()

// ========= BLUESPACE BEACON ============

/obj/machinery/gate_beacon
	name = "bluespace beacon"
	desc = "A beacon used to open gates into bluespace."
	icon = 'icons/rust.dmi'
	icon_state = "injector-emitting"
	density = 1
	opacity = 0
	anchored = 1
	unacidable = 1
	l_color = "#142933"
	luminosity = 0
	var/functional = 1
	var/charge = 0 // Used for charging a bluespace gate
	var/max_charge = 10000 // Used for charging a bluespace gate
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
		luminosity = 2

		..()


/obj/machinery/gate_beacon/Del()
	bluespace_beacons["[name]"] = null


/obj/machinery/gate_beacon/process()
	if( charge >= max_charge )
		open_gate( exit )

/obj/machinery/gate_beacon

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



/proc/getWarpIcon( var/icon/A )//If safety is on, a new icon is not created.
	var/icon/flat_icon = new(A)//Has to be a new icon to not constantly change the same icon.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "warp")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon

/obj/machinery/gate_beacon/proc/charge( var/charge_rate )
	charge += charge_rate

/obj/machinery/gate_beacon/proc/activate( var/obj/machinery/gate_beacon/dest = null )
	exit = dest

	if( inducers.len < 1 )
		ping("[src] states, \"ERROR: No bluespace inducers nearby!\"")
	for( var/obj/machinery/power/bluespace_inducer/inducer in inducers )
		inducer.activate( src )

// ========= BLUESPACE GATE CONTROL CONSOLE =========

/obj/machinery/computer/gate_beacon_console
	name = "bluespace beacon console"
	desc = "A console used to set the destination for bluespace gates."
	icon = 'icons/rust.dmi'
	icon_state = "fuel0"
	use_power = 0
	var/obj/machinery/gate_beacon/beacon = null
	var/functional = 0

/obj/machinery/computer/gate_beacon_console/New()
	find_beacon()

	..()

/obj/machinery/computer/gate_beacon_console/update_icon()
	if( functional )
		icon_state = "power"
	else
		icon_state = "fuel0"

/obj/machinery/computer/gate_beacon_console/proc/find_beacon()
	for( beacon in orange( 7, src ))
		break
	if( beacon )
		functional = 1
		update_icon()
		return 1
	else
		return 0

/obj/machinery/computer/gate_beacon_console/proc/gate_prompt( var/user = usr )
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