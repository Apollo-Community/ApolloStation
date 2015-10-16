/turf/var/list/autocells = list()

/turf/proc/containsCell( var/cell_type )
	if( locate( cell_type ) in src.autocells )
		return 1

	return 0

/atom/movable/cell
	icon = 'icons/effects/effects.dmi'
	icon_state = "cellauto"

	anchored = 1

	var/age = 0 // how many iterations this cell has survived
	var/age_max = 3 // Maximum number of iterations this cell will survive
	var/datum/cell_auto_master/master = null
	var/master_type = /datum/cell_auto_master

/atom/movable/cell/New( loc as turf, var/set_master = null )
	..()

	var/turf/T = get_turf( src )
	if( T ) // Checking and setting the turf's automata cell
		if( T.containsCell( type ))
			qdel( src )
			return
		else
			T.autocells += src
	else
		qdel( src )
		return

	if( !set_master )
		master = PoolOrNew( master_type )
	else
		master = set_master

	master.cells += src

/atom/movable/cell/proc/process()
	if( src.shouldDie() )
		qdel( src )

	if( master )
		if( !master.shouldProcess() )
			qdel( src )

	return

/atom/movable/cell/proc/shouldProcess()
	if( age_max )
		if( age >= age_max )
			return 0

	return 1

/atom/movable/cell/proc/shouldDie()
	if( age_max )
		if( age >= age_max )
			return 1

	return 0

/atom/movable/cell/proc/spread()
	return

/atom/movable/cell/Destroy()
	var/turf/T = get_turf( src )

	if( T )
		T.autocells -= src

	if( master )
		master.cells -= src

	master = null

	..()

	return

/atom/movable/cell/singularity_act()
	return

/atom/movable/cell/singularity_pull()
	return

/atom/movable/cell/ex_act()
	return
