/atom/movable/cell/blotch
	name = "the blotch"
	desc = "A horrible fleshy mess, it sticks to the bottom of your shoes."

	anchored = 1
	opacity = 0
	density = 0

	icon = 'icons/effects/effects.dmi'
	icon_state = "planner"
	layer = 2.1

	age_max = 4 // The tile will try to spread 4 times and then sleep until awoken
	master_type = /datum/cell_auto_master/blotch

	var/health = 30

/atom/movable/cell/blotch/process()
	checkDeath()

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		spread()

	age++

/atom/movable/cell/blotch/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/blotch, list( T, master ))

/atom/movable/cell/blotch/shouldProcess()
	if( age >= age_max )
		return 0

	if( !master )
		return 0

	return 1

/atom/movable/cell/blotch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	health -= W.force

	checkDeath()

/atom/movable/cell/blotch/ex_act(severity)
	health -= ( 4-severity )*10.0

	checkDeath()

/atom/movable/cell/blotch/bullet_act(var/obj/item/projectile/P)
	..()

	health -= P.damage

	checkDeath()

/atom/movable/cell/blotch/shouldDie()
	if( health <= 0 )
		return 1

	if( !isfloor( get_turf( src )))
		return 1

	return 0

/atom/movable/cell/blotch/proc/revive()
	age = 0

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

	if( !isfloor( T ))
		return 0

	if( T.contains_dense_objects() )
		return 0

	return 1

/atom/movable/cell/blotch/proc/kill()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		var/atom/movable/cell/blotch/B = locate( type ) in T
		if( B )
			B.revive()

/datum/cell_auto_master/blotch
	cell_type = /atom/movable/cell/blotch
	group_age_max = 0

/datum/cell_auto_master/blotch/New( var/loc as turf )
	..()

	blotch_handler.masters += src

/datum/cell_auto_master/blotch/Destroy()
	kill()

	blotch_handler.masters -= src

	..()