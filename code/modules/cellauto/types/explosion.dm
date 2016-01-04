/atom/movable/cell/explosion
	name = "explosion"
	desc = ""
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"

	layer = 9.99

	age_max = 0

	light_range = 1
	light_color = FIRE_COLOR
	light_power = 1

	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSBLOB

	master_type = /datum/cell_auto_master/explosion

	var/age_process_max = 2
	var/cached = 0 // have we already cached this turf?
	var/non_cache_chance = 5 // the chance we'll break now istead of caching
	var/spread_chance = 85 // Introducing a little randomness to explosion expansion

/atom/movable/cell/explosion/New()
	..()
	update_icon()

/atom/movable/cell/explosion/proc/update_icon()
	..()

	var/datum/cell_auto_master/explosion/M = master

	icon_state = "[4-M.getSeverity()]"

/atom/movable/cell/explosion/process()
	if( shouldDie() )
		qdel(src)

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		if( !loc.Enter( src ))
			if( canCache() )
				addToCache()
		else
			if( canCache() )
				addToCache()
			spread()

/atom/movable/cell/explosion/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ) && prob( spread_chance ))
			PoolOrNew( /atom/movable/cell/explosion, list( T, master ))

/atom/movable/cell/explosion/proc/canCache()
	return !cached

/atom/movable/cell/explosion/proc/addToCache()
	var/turf/T = loc

	if( !T )
		return

	var/datum/cell_auto_master/explosion/M = master
	var/severity = M.getSeverity()

	for( var/atom/movable/AM in T.contents )
		if( prob( non_cache_chance ) || istype( AM, /mob ))
			AM.ex_act( severity )
		else
			M.ex_act_cache[AM] = severity

	if( iswall( T ) || prob( non_cache_chance )) // Need to break down walls as we get to them so explosions dont get stuck in single rooms
		T.ex_act( severity )
	else
		M.ex_act_cache[T] = severity

	M.affected_turfs += T

/atom/movable/cell/explosion/shouldProcess()
	if( age > age_process_max )
		return 0

	return 1

/atom/movable/cell/explosion/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.containsCell( type ))
		return 0

	var/datum/cell_auto_master/explosion/M = master
	if( M )
		if( T in M.affected_turfs )
			return 0

	return 1

/datum/cell_auto_master/explosion
	cell_type = /atom/movable/cell/explosion

	group_age_max = 0

	var/devastation_range
	var/heavy_impact_range
	var/light_impact_range

	var/start
	var/end
	var/turf/start_loc

	var/powernet_rebuild_deferred
	var/air_processing_deferred

	var/list/affected_turfs = list()
	var/list/ex_act_cache = list() // This caches all of the items to be ex_act'd all at once, trust me, its faster

/datum/cell_auto_master/explosion/shouldProcess()
	if( group_age <= devastation_range || group_age <= heavy_impact_range || group_age <= light_impact_range )
		return 1
	else
		return 0

/datum/cell_auto_master/explosion/New( var/loc as turf, var/devastation, var/heavy_impact, var/light_impact )
	..()

	start_loc = loc

	devastation_range = devastation
	heavy_impact_range = heavy_impact
	light_impact_range = light_impact

	explosion_handler.masters += src

	start = world.timeofday

	air_processing_deferred = air_processing_killed

	if( !air_processing_deferred )
		air_processing_killed = 1

/datum/cell_auto_master/explosion/Destroy()
	explosion_handler.masters -= src
	affected_turfs.Cut()

	if( !air_processing_deferred )
		air_processing_killed = 0

	..()

/datum/cell_auto_master/explosion/process()
	..()

	if( !getSeverity() ) // If we're done expanding, process the cache
		processCache()

	if( !getSeverity() && !shouldProcess() )
		if( !end )
			end = world.timeofday
			var/took = (end-start)/10
			if(Debug2)
				//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
				world << "## DEBUG: Explosion([start_loc.x],[start_loc.y],[start_loc.z])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		decayExplosion() // Makes the explosion fizzle away

/datum/cell_auto_master/explosion/proc/processCache()
	for( var/atom/AM in ex_act_cache )
		AM.ex_act( ex_act_cache[AM] )

	ex_act_cache.Cut()

/datum/cell_auto_master/explosion/proc/decayExplosion()
	for( var/i = 0, i < cells.len/2, i++ )
		qdel( pick( cells ))

/datum/cell_auto_master/explosion/proc/getSeverity()
	if( group_age <= devastation_range )
		return 1.0
	else if( group_age <= heavy_impact_range )
		return 2.0
	else if( group_age <= light_impact_range )
		return 3.0
	else
		return 0