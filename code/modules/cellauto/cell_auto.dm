/turf/var/autocell = null

/atom/movable/cell
	name = ""
	desc = ""
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
		if( T.autocell )
			qdel( src )
			return
		else
			T.autocell = src
	else
		testing( "Cell existsed on non-turf" )
		qdel( src )
		return

	if( !set_master )
		master = new master_type()
	else
		master = set_master

	master.cells += src

/atom/movable/cell/proc/process()
	if( age >= age_max )
		qdel( src )

	if( master )
		if( !master.shouldProcess() )
			qdel( src )

	return

/atom/movable/cell/proc/shouldProcess()
	if( age >= age_max )
		return 0

	return 1

/atom/movable/cell/Destroy()
	var/turf/T = get_turf( src )

	if( T )
		T.autocell = null

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
