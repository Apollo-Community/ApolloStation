var/global/list/bluespace_beacons = list()

/obj/machinery/warp_beacon
	name = "bluespace beacon"
	desc = "A beacon used to warp to other sectors"
	icon = 'icons/rust.dmi'
	icon_state = "injector-emitting"
	density = 1
	opacity = 0
	anchored = 1
	unacidable = 1
	l_color = "#142933"
	var/brightness = 2
	var/functional = 1
	var/obj/effect/map/sector = null
	var/turf/exit = null

/obj/machinery/warp_beacon/New()
	src.ping("[src] states, \"Initializing...\"")
	spawn(20)
		sector = map_sectors["[z]"]
		if( !sector )
			functional = 0
			src.ping("[src] states, \"ERROR: Critical error with the bluespace network!\"")
			return

		exit = get_step(src, dir)
		if( !istype( exit, /turf/simulated/floor ) && !istype( exit, /turf/space ))
			functional = 0
			src.ping("[src] states, \"ERROR: Warp location blocked!\"")
			return

		SetLuminosity(brightness)

		if( name == "bluespace beacon" )
			var/hash = "[pick( alphabet_uppercase )][pick( alphabet_uppercase )][rand(0, 9)]"
			name = "Bluespace Beacon [hash]-[sector.x][sector.y]"

		bluespace_beacons["[name]"] = src

		..()

/obj/machinery/warp_beacon/Del()
	bluespace_beacons["[name]"] = null

/obj/machinery/warp_beacon/Bumped(atom/AM)
	if( istype( AM, /atom/movable ))
		warp_prompt( AM )

/obj/machinery/warp_beacon/proc/warp_prompt( var/atom/movable/AM, var/user = usr )
	var/obj/machinery/warp_beacon/destination

	var/list/bluespace_beacons_dest = bluespace_beacons
	bluespace_beacons_dest.Remove( src )

	destination = input( user, "Where would you like to warp to?", "Destination", destination ) in bluespace_beacons_dest

	if( destination )
		warp( AM, bluespace_beacons[destination] )

/obj/machinery/warp_beacon/proc/warp( var/atom/movable/AM, var/obj/machinery/warp_beacon/dest )
	if( src == dest )
		src.ping("[src] states, \"ERROR: Critical error with the bluespace network!\"")
		return
	if( !functional )
		src.ping("[src] states, \"ERROR: [name] failed to interface with bluespace network!\"")
		return
	if( !dest.functional )
		src.ping("[src] states, \"ERROR: [name] failed to interface with destination beacon!\"")
		return

	src.ping("[src] states, \"Transmitting object \"[AM]\" via micro-packet transmission. Standby.\"")
	dest.ping("[dest] states, \"Incoming object \"[AM]\".\"")

	// Doing the warp animation
	flick( getWarpIcon( AM.icon ), AM )

	// Jumping to the location
	AM.loc = dest.exit
	src.ping("[src] states, \"Object \"[AM]\" transmitted.\"")
	dest.ping("[dest] states, \"Object \"[AM]\" recieved.\"")

/proc/getWarpIcon( var/icon/A )//If safety is on, a new icon is not created.
	var/icon/flat_icon = new(A)//Has to be a new icon to not constantly change the same icon.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "warp")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon