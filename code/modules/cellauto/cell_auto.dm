/turf/var/autocell = null

/atom/movable/cell
	name = ""
	desc = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "cellauto"

	anchored = 1

	var/age = 0 // how many iterations this cell has survived
	var/age_max = 3 // Maximum number of iterations this cell will survive

/atom/movable/cell/New()
	..()

	var/turf/T = get_turf( src )
	if( T ) // Checking and setting the turf's automata cell
		if( T.autocell )
			qdel( src )
			return
		else
			T.autocell = src
	else
		qdel( src )
		return

/atom/movable/cell/proc/process()
	return

/atom/movable/cell/Destroy()
	var/turf/T = get_turf( src )
	T.autocell = null

	..()

	return
