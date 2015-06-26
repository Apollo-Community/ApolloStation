/obj/effect/traveler
	name = "Stellar Object"
	desc = "An object that seems to be flying out in the void of space."

	icon = 'icons/effects/sectors.dmi'
	icon_state = "spacepod"
	animate_movement = 0

	var/atom/movable/object = null // The object that the traveler represents, usually just spacepods

/obj/effect/traveler/New( var/atom/movable/new_object )
	object = new_object

	if( !object )
		del( src )

	name = object.name
	desc = object.desc

	src.loc = getOvermapLoc( object )
	step( src, object.dir )

	object.Move( src )

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
	testing( "enterLocal() called" )

	var/obj/effect/map/sector/sector = locate( /obj/effect/map/sector ) in get_turf( src )

	if( sector )
		// Put in the local sector based on where they were in the overmap
		var/obj_x = round((( pixel_x+16 )/32 )*( world.maxx-( 2*OVERMAP_EDGE )))
		var/obj_y = round((( pixel_y+16 )/32 )*( world.maxy-( 2*OVERMAP_EDGE )))

		switch( src.dir )
			if( NORTH )
				obj_y = ( OVERMAP_EDGE+3 )
			if( SOUTH )
				obj_y = world.maxy-( OVERMAP_EDGE+3 )
			if( WEST )
				obj_x = world.maxx-( OVERMAP_EDGE+3 )
			if( EAST )
				obj_x = ( OVERMAP_EDGE+3 )

		testing( "Attempting to place object in sector" )
		var/turf/T = locate( obj_x, obj_y, sector.map_z )
		if( T )
			object.loc = T
			object.dir = src.dir
			object = null
			del( src )
	else
		testing( "Could not place object in sector" )
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