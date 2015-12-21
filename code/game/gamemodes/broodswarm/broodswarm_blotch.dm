/atom/movable/cell/blotch
	name = "blotch"
	desc = "A horrible fleshy mess, it sticks to the bottom of your shoes."

	anchored = 1
	opacity = 0
	density = 0

	icon = 'icons/effects/blotch.dmi'
	icon_state = "1"
	layer = 2.1

	light_color = "#660033"
	light_range = 2

	age_max = 0
	master_type = /datum/cell_auto_master/blotch

	var/global/health_per_process = 10
	var/global/health_states = 5
	var/health = 10
	var/max_health = 100 // The tile will try to spread until its at max health
	var/min_health = 1

/atom/movable/cell/blotch/New()
	..()

	update_icon()

/atom/movable/cell/blotch/Destroy()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		var/atom/movable/cell/blotch/B = locate( type ) in T
		if( B )
			B.revive()

	..()

/atom/movable/cell/blotch/proc/update_icon()
	var/icon_value = round( health/( max_health/health_states ))
	icon_state = "[icon_value]"

/atom/movable/cell/blotch/process()
	processHealth()

	if( shouldProcess() && master.shouldProcess() )
		spread()
		update_icon()
	else
		kill() // fall asleep until something happens

/atom/movable/cell/blotch/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/blotch, list( T, master ))

/atom/movable/cell/blotch/examine(mob/user)
	..()

	if( health <= max_health/4 )
		user << "It appears to be soft."
	else if( health <= max_health/2 )
		user << "It appears to be partially hardened."
	else if( health <= (max_health/4)*3 )
		user << "It appears to be almost fully hardened."
	else
		user << "It appears to be fully hardened."

/atom/movable/cell/blotch/shouldProcess()
	if( max_health )
		if( health >= max_health )
			return 0

	if( !master )
		return 0

	return 1

/atom/movable/cell/blotch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	health -= W.force

	checkDeath()

	revive()

/atom/movable/cell/blotch/ex_act(severity)
	health -= ( 4-severity )*10.0

	checkDeath()

	revive()

/atom/movable/cell/blotch/bullet_act(var/obj/item/projectile/P)
	..()

	health -= P.damage

	checkDeath()

	revive()

/atom/movable/cell/blotch/shouldDie()
	if( min_health )
		if( health < min_health )
			return 1

	if( !isfloor( get_turf( src )))
		return 1

	return 0

/atom/movable/cell/blotch/proc/processHealth()
	checkDeath()

	health = min( max_health, health+health_per_process )

/atom/movable/cell/blotch/proc/kill()
	if( src in master.cells )
		master.cells -= src

	update_icon()

/atom/movable/cell/blotch/proc/revive()
	if( !( src in master.cells ))
		master.cells += src

	update_icon()

/atom/movable/cell/blotch/proc/checkDeath()
	if( shouldDie() )
		qdel( src )
		return 1
	return 0

/atom/movable/cell/blotch/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.containsCell( type ))
		return 0

	if( !T.Enter( src ))
		return 0

	return 1

/datum/cell_auto_master/blotch
	cell_type = /atom/movable/cell/blotch
	group_age_max = 0
	var/turf/location

/datum/cell_auto_master/blotch/New( var/loc as turf )
	..()

	location = loc

	blotch_handler.masters += src

/datum/cell_auto_master/blotch/Destroy()
	blotch_handler.masters -= src

	..()

/datum/cell_auto_master/blotch/process()
	group_age++

	for( var/atom/movable/cell/cell in cells )
		cell.process()

	if( location && cell_type )
		if( !( location.containsCell( cell_type )))
			PoolOrNew( cell_type, list( location, src )) // If our home location doesn't have a cell, add a new one
