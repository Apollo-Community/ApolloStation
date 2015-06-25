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

/proc/getOvermapLoc( var/atom )
	var/turf/T = get_turf( atom )
	var/obj/effect/map/M = map_sectors["[T.z]"]

	return get_turf( M )

/*
proc/overmap_spacetravel( var/turf/space/T, var/atom/movable/A )
	var/obj/effect/map/M = map_sectors["[T.z]"]
	if (istype( A, /obj/item )) // Optimization to keep spacejunk from killing the server
		statistics.increase_stat("trash_vented")
		spawn(0)
			del(A)
		return
	if (!M)
		return
	var/mapx = M.x
	var/mapy = M.y
	var/nx = A.x
	var/ny = A.y
	var/nz = M.map_z

	if(T.x <= TRANSITIONEDGE)
		nx = world.maxx - TRANSITIONEDGE - 2
		mapx = max(1, mapx-1)

	else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
		nx = TRANSITIONEDGE + 2
		mapx = min(world.maxx, mapx+1)

	if (T.y <= TRANSITIONEDGE)
		ny = world.maxy - TRANSITIONEDGE -2
		mapy = max(1, mapy-1)

	else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
		ny = TRANSITIONEDGE + 2
		mapy = min(world.maxy, mapy+1)

	testing("[A] moving from [M] ([M.x], [M.y]) to ([mapx],[mapy]).")

	var/turf/map = locate(mapx,mapy,OVERMAP_ZLEVEL)
	var/obj/effect/map/TM = locate() in map
	if(TM)
		nz = TM.map_z
		testing("Destination: [TM]")
	else
		if(cached_space.len)
			var/obj/effect/map/sector/temporary/cache = cached_space[cached_space.len]
			cached_space -= cache
			nz = cache.map_z
			cache.x = mapx
			cache.y = mapy
			testing("Destination: *cached* [TM]")
		else
			world.maxz++
			nz = world.maxz
			lighting_controller.initializeLighting(nz)
			TM = new /obj/effect/map/sector/temporary(mapx, mapy, nz)
			testing("Destination: *new* [TM]")

	var/turf/dest = locate(nx,ny,nz)
	if(dest)
		A.loc = dest

	if(istype(M, /obj/effect/map/sector/temporary))
		var/obj/effect/map/sector/temporary/source = M
		if (source.can_die())
			testing("Caching [M] for future use")
			source.loc = null
			cached_space += source
*/