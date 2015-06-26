/obj/effect/traveler
	name = "Stellar Object"
	desc = "An object that seems to be flying out in the void of space."

	icon = 'icons/effects/sectors.dmi'
	icon_state = "spacepod"

	var/atom/movable/object = null // The object that the traveler represents, usually just spacepods

/obj/effect/traveler/New( object = null )
	if( !object )
		del( src )

	loc = getOvermapLoc( object )

/obj/effect/traveler/relaymove( mob/user, direction )
	if( !object )
		return

	if( istype( object, /obj/spacepod ))
		var/obj/spacepod/SP = object

		if( !SP.canMove() )
			return

	handleMovement( direction )

/obj/effect/traveler/proc/handleMovement( var/direction )
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
	if( /obj/effect/map/sector in get_turf( src ))
		var/obj/effect/map/sector/sector = locate( /obj/effect/map/sector )

		var/obj_x = rand( OVERMAP_EDGE, world.maxx-OVERMAP_EDGE )
		var/obj_y = rand( OVERMAP_EDGE, world.maxy-OVERMAP_EDGE )

		switch( src.dir )
			if( NORTH )
				obj_y = world.maxy-OVERMAP_EDGE
			if( SOUTH )
				obj_y = OVERMAP_EDGE
			if( WEST )
				obj_x = OVERMAP_EDGE
			if( EAST )
				obj_x = world.maxx-OVERMAP_EDGE

		var/turf/T = locate( obj_x, obj_y, sector.map_z )
		if( T )
			object.loc = T
			object = null
			del( src )
	else
		usr << "It doesn't seem like there's anything of interest in this sector."

/proc/getOvermapLoc( var/atom )
	var/turf/T = get_turf( atom )
	var/obj/effect/map/M = map_sectors["[T.z]"]

	return get_turf( M )


/atom/movable/proc/overmapTravel()
	var/move_to_z = src.z
	var/safety = 1

	while(move_to_z == src.z)
		var/move_to_z_str = pickweight(accessible_z_levels)
		move_to_z = text2num(move_to_z_str)
		safety++
		if(safety > 10)
			break

	if(!move_to_z)
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