/obj/effect/traveler
	name = "Stellar Object"
	desc = "An object that seems to be flying out in the void of space."

	icon = 'icons/effects/sectors.dmi'
	icon_state = "spacepod"
	animate_movement = 0

	var/atom/movable/object = null // The object that the traveler represents, usually just spacepods
	var/frozen = 0 // Used to prevent movement
	var/global/list/travelling_landing_zones = list()

/obj/effect/traveler/New( var/atom/movable/new_object )
	object = new_object

	if( !object )
		qdel( src )

	name = object.name
	desc = object.desc

	src.loc = getOvermapLoc( object )
	step( src, object.dir )

	switch( object.dir )
		if( NORTH )
			pixel_y = -16
		if( SOUTH )
			pixel_y = 15
		if( WEST )
			pixel_x = 15
		if( EAST )
			pixel_x = -16

	object.Move( src )

/obj/effect/traveler/relaymove( mob/user, direction )
	if( !object )
		return

	if( frozen )
		return

	if( istype( object, /obj/spacepod ))
		var/obj/spacepod/SP = object

		if( !SP.canMove() )
			return

	handleMovement( direction )

/obj/effect/traveler/proc/handleMovement( var/direction = src.dir )
	if( !direction )
		return

	src.dir = direction

	switch( direction )
		if( NORTH )
			if( pixel_y >= 16 )
				src.pixel_y = -16
				step(src, direction)
			else
				pixel_y++
		if( SOUTH )
			if( pixel_y < -16 )
				src.pixel_y = 16
				step(src, direction)
			else
				pixel_y--
		if( WEST )
			if( pixel_x < -16 )
				src.pixel_x = 16
				step(src, direction)
			else
				pixel_x--
		if( EAST )
			if( pixel_x >= 16 )
				src.pixel_x = -16
				step(src, direction)
			else
				pixel_x++

/obj/effect/traveler/proc/enterLocal()
	var/obj/effect/map/sector/sector = locate( /obj/effect/map/sector ) in get_turf( src )

	if( sector )
		fadeout()

		sleep( 5 )
		if( alert_user( "Would you like to enter sector \"[sector.real_name]\"?" ) == "No" )
			fadein()

			src.dir = turn( src.dir, 180 )
			handleMovement( src.dir ) // Turn them around and move them away from the sector

			return

		// Landing on a moon or other planetoid
		if( sector.metadata && sector.metadata.landing_area )
			var/area/planet/moon/landing_zone/destination
			var/mob/user = usr
			var/list/landing_zone_dest = list()
			for( var/name in travelling_landing_zones )
				var/area/planet/moon/landing_zone/B = travelling_landing_zones[name]
				landing_zone_dest.Add( B )

			destination = input( user, "Where would you like to land?", "Destination", destination ) in landing_zone_dest
			if( destination )
				sector.metadata.landing_area = destination
			else
				usr << "No valid landing site chosen!"
				fadein()

				src.dir = turn( src.dir, 180 )
				handleMovement( src.dir ) // Turn them around and move them away from the sector

				return
			var/area/A = locate( sector.metadata.landing_area ) in return_areas()
			var/turf/T = pick( get_area_turfs( A ))
			if( T )
				object.loc = T
				object.dir = src.dir

				fadein()

				object = null
				qdel( src )
				return

			fadein()
			return

		var/edge_length = sector.metadata.edge_length

		var/x_normal = ( pixel_x+16 )/32 // Normalized values to find out where along they edge they are
		var/y_normal = ( pixel_y+16 )/32

		// Put in the local sector based on where they were in the overmap
		var/obj_x = round( x_normal*( world.maxx-( edge_length*2 )))+edge_length
		var/obj_y = round( y_normal*( world.maxy-( edge_length*2 )))+edge_length

		switch( src.dir )
			if( NORTH )
				obj_y = ( edge_length+TRANSITION_EDGE_BUFFER )
			if( SOUTH )
				obj_y = world.maxy-( edge_length+TRANSITION_EDGE_BUFFER )
			if( WEST )
				obj_x = world.maxx-( edge_length+TRANSITION_EDGE_BUFFER )
			if( EAST )
				obj_x = ( edge_length+TRANSITION_EDGE_BUFFER )

		var/turf/T = locate( obj_x, obj_y, sector.map_z )
		if( T )
			object.loc = T
			object.dir = src.dir

			fadein()

			object = null
			qdel( src )
			return

	fadein()
	usr << "It doesn't seem like there's anything of interest in this sector."

/obj/effect/traveler/proc/alert_user( var/message = "Would you like to answer this question?" )
	if( istype( object, /obj/spacepod ))
		var/obj/spacepod/SP = object
		if( SP.pilot )
			return alert( SP.pilot, message,,"Yes","No" )
		else
			return "No"

	if( istype( object, /mob ))
		var/mob/M = object
		return alert( M, message,,"Yes","No" )

/obj/effect/traveler/proc/fadeout()
	frozen = 1 // you might stub your toe in the dark

	if( istype( object, /obj/spacepod ))
		var/obj/spacepod/SP = object
		SP.fadeout()

	if( istype( object, /mob ))
		var/mob/M = object
		M.fadeout()

/obj/effect/traveler/proc/fadein()
	frozen = 0

	if( istype( object, /obj/spacepod ))
		var/obj/spacepod/SP = object
		SP.fadein()

	if( istype( object, /mob ))
		var/mob/M = object
		M.fadein()

/proc/getOvermapLoc( var/atom )
	var/turf/T = get_turf( atom )
	var/obj/effect/map/M = overmap.map["[T.z]"]

	return get_turf( M )

/atom/movable/proc/overmapTravel()
	var/move_to_z = src.z
	var/safety = 1

	while(move_to_z == src.z)
		var/obj/effect/map/sector/sector = overmap.map["[pick( overmap.local_levels )]"]

		safety++

		if(safety > 10)
			break

		if( !istype( sector ))
			continue

		if( sector.canRandomTeleport() )
			move_to_z = sector.map_z

	if(move_to_z == src.z)
		return

	src.z = move_to_z

	if(src.x <= TRANSITIONEDGE)
		src.x = world.maxx - TRANSITIONEDGE - 2
		src.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

	else if (src.x >= (world.maxx - TRANSITIONEDGE - 1))
		src.x = TRANSITIONEDGE + 1
		src.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

	else if (src.y <= TRANSITIONEDGE)
		src.y = world.maxy - TRANSITIONEDGE -2
		src.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

	else if (src.y >= (world.maxy - TRANSITIONEDGE - 1))
		src.y = TRANSITIONEDGE + 1
		src.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

	spawn (0)
		if ((src && src.loc))
			src.loc.Entered(src)
