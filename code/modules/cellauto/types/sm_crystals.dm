/atom/movable/cell/supermatter_crystals
	name = "supermatter crystals"

	anchored = 1
	opacity = 0
	density = 0

	icon = 'icons/obj/supermatter.dmi'
	icon_state = "floor_crystal"
	layer = 2.1

	max_age = 0

	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3

	age_max = 0 // Maximum number of iterations this cell will survive
	master_type = /datum/cell_auto_master/supermatter_crystal

	var/smlevel = 0
	var/has_spread = 0

/atom/movable/cell/supermatter_crystals/proc/update_icon()
	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		color = getSMColor( M.smlevel )
		light_color = getSMColor( M.smlevel )

		set_light( light_range, light_power, light_color )

	..()

/atom/movable/cell/supermatter_crystals/process()
	if( shouldDie() )
		qdel(src)

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		spread()
		convert()

/atom/movable/cell/supermatter_crystals/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/supermatter_crystals, list( T, master ))

/atom/movable/cell/supermatter_crystals/shouldProcess()
	if( age > 1 )
		return 0

	return 1
ww
/atom/movable/cell/supermatter_crystals/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.autocell )
		return 0

	if( !iswall( T ))
		return 0

	return 1


/datum/cell_auto_master/supermatter_crystal
	var/smlevel = 1
	cell_type = /atom/movable/cell/supermatter_crystals

/datum/cell_auto_master/supermatter_crystal/New( var/loc as turf, size = 0, var/level = 0 )
	..()

	if( level )
		smlevel = level

	sm_crystal_handler.masters += src

/datum/cell_auto_master/supermatter_crystal/Destroy()
	sm_crystal_handler.masters -= src

	..()