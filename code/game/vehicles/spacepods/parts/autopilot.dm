/obj/item/device/spacepod_equipment/misc/autopilot
	name = "\improper autopilot system"
	desc = "Used to automatically pilot the shuttle to known locations."
	icon_state = "autopilot"
	var/piloting = 0 // Are we currently on autopilot?
	var/obj/machinery/gate_beacon/destination = null
	var/list/path = null
	var/turf/local_end = null
	var/obj/effect/map/sector = null // The current sector
	manufacturer = "Ward-Takahashi GMB"

/obj/item/device/spacepod_equipment/misc/autopilot/Destroy()
	if( processing_objects[src] )
		processing_objects.Remove( src )

	..()

/obj/item/device/spacepod_equipment/misc/autopilot/process()
	if( piloting )
		if( path ) // If we have our map acrossed the sectors, do our stuff
			if( sector != map_sectors["[my_atom.z]"] ) // If we're in a new sector
				testing( "[my_atom] entered a new sector" )
				sector = map_sectors["[my_atom.z]"]
				path.Remove( sector ) // Removing the current sector from the list of destinations
				local_end = get_end()

			if( local_end ) // If we have a local path across the sector, do your magic
				if( my_atom.loc != local_end ) // Local path len will only fall to this low if we actually reach the end
					my_atom.set_dir( get_dir( my_atom,local_end ))
					var/turf/T = get_step( my_atom.loc, my_atom.dir )
					my_atom.Move( T )
				else // If we arrived
					testing( "[my_atom] arrived at destination [destination]" )
					quit_pilot()
			else // If not, we need to make one
				testing( "Finding new local_end" )
				local_end = get_end()

		else // Otherwise, we need one asap
			get_path()
	else
		testing( "process() quit piloting" )
		quit_pilot()
		processing_objects.Remove( src )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/prompt( var/mob/user = usr )
	testing( "Starting autopilot sequence" )
	testing( "prompt() called" )

	var/target = input( user, "Where would you like to fly to?", "Destination", null ) in bluespace_beacons
	destination = bluespace_beacons[target]

	if( destination )
		get_path()

		if( path )
			testing( "Successfully found a path" )
			piloting = 1
			spawn( 30 )
				processing_objects.Add( src )
		else
			testing( "Could not find a path" )
			my_atom.occupants_announce( "Could not plot a course to [target]!" )
	else
		my_atom.occupants_announce( "Autopilot aborted." )
		testing( "Autopilot sequence aborted" )

	if( piloting )
		testing( "prompt() completed successfully" )
	else
		testing( "prompt() completed unsuccessfully" )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_path()
	testing( "get_path() called" )
	path = null

	if( !destination )
		testing( "No valid destination" )
		quit_pilot()
		return

	sector = map_sectors["[my_atom.z]"] // getting our current sector
	var/obj/effect/map/target = map_sectors["[destination.z]"] // getting our destination sector

	if( !sector )
		my_atom.occupants_announce( "Spacepod is not in a valid sector!" )
		testing( "Could not find pod sector" )
		quit_pilot()
		return
	if( !target )
		my_atom.occupants_announce( "Destination is not a valid target!" )
		testing( "Could not find destination sector" )
		quit_pilot()
		return

	path = AStar(sector.loc, target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 0 )

	if( path )
		testing( "get_path() returned with a path" )
	else
		testing( "get_path() returned without a path" )

	return path

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_end()
	testing( "get_end() called" )
	var/turf/start = my_atom.loc
	var/turf/end = null

	if( start )
		testing( "start found at [start]" )
	else
		testing( "start found nothing" )

	if( path )
		if( path.len > 1 )
			testing( "Finding edge of next sector" )
			var/obj/effect/map/next_sector = path[1]

			switch( get_dir( sector, next_sector ))
				if(NORTH)
					end = locate( start.x, world.maxy-1, start.z )
				if(SOUTH)
					end = locate( start.x, 1, start.z )
				if(EAST)
					end = locate( world.maxx-1, start.y, start.z )
				if(WEST)
					end = locate( 1, start.y, start.z )

			if( end )
				testing( "end found end at [end]" )
			else
				testing( "end found at nothing" )
		else
			testing( "Finding destination" )
			end = destination.loc
	else
		testing( "no sector path" )

	if( end )
		testing( "end_turf() returned with [end]" )
	else
		testing( "end_turf() returned with null" )

	return end

/proc/greater_or_less( var/a, var/b )
	if( a > b )
		return -1
	else if( a == b )
		return 0
	else if( a < b )
		return 1


/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_local_path( var/turf/end )
	testing( "get_local_path() called" )
	testing( "Finding local path from [my_atom.loc] to [end]" )
	local_path = list()
	var/pathx_it = greater_or_less( my_atom.x, end.x  )
	var/pathy_it = greater_or_less( my_atom.y, end.y )

	if( pathx_it != 0 && pathy_it != 0 )
		for( var/pathx = my_atom.x; pathx != end.x; pathx += pathx_it )
			for( var/pathy = my_atom.y; pathy != end.y; pathy += greater_or_less( pathy, my_atom.y ))
				var/turf/T = locate( pathx, pathy, my_atom.z )

				local_path.Add(T)
			if( local_path.len >= world.maxx )
				break
	else if( pathx_it != 0 )
		for( var/pathx = my_atom.x; pathx != end.x; pathx += pathx_it )
			var/turf/T = locate( pathx, my_atom.y, my_atom.z )

			local_path.Add(T)

			if( local_path.len >= world.maxx )
				break
	else if( pathy_it != 0 )
		for( var/pathy = my_atom.y; pathy != end.y; pathy += pathy_it )
			var/turf/T = locate( my_atom.x, pathy, my_atom.z )

			local_path.Add(T)

			if( local_path.len >= world.maxx )
				break


	if( local_path )
		testing( "get_local_path() returned with a path" )
	else
		testing( "get_local_path() returned without a path" )

	return local_path


/obj/item/device/spacepod_equipment/misc/autopilot/proc/quit_pilot()
	testing( "quit_pilot() called" )

	if( processing_objects[src] )
		processing_objects.Remove( src )

	piloting = 0
	path = null
	local_end = null
	destination = null

	testing( "quit_pilot() returned" )