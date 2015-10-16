/atom/movable/cell/supermatter_crystals
	name = "supermatter crystals"

	anchored = 1
	opacity = 0
	density = 0

	icon = 'icons/obj/supermatter.dmi'
	icon_state = "floor_crystal"
	layer = 2.1

	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3

	age_max = 0 // There is no maximum age
	master_type = /datum/cell_auto_master/supermatter_crystal

	var/smlevel = 1
	var/has_spread = 0
	var/health = 30

/atom/movable/cell/supermatter_crystals/New()
	..()

	if( !iswall( loc ))
		if( prob( 90 ))
			qdel( src )

	update_icon()

/atom/movable/cell/supermatter_crystals/proc/update_icon()
	if( iswall( get_turf( src )))
		icon_state = "wall_crystal"
	else
		icon_state = "floor_crystal"

	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		color = getSMColor( M.smlevel )
		light_color = color

		set_light( light_range, light_power, light_color )

	..()

/atom/movable/cell/supermatter_crystals/process()
	if( shouldDie() )
		qdel( src )

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		spread()
		radiate()

/atom/movable/cell/supermatter_crystals/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/supermatter_crystals, list( T, master ))

/atom/movable/cell/supermatter_crystals/proc/radiate()
	for(var/mob/living/l in range(src, smlevel ))
		var/rads = smlevel*5
		l.apply_effect(rads, IRRADIATE)

/atom/movable/cell/supermatter_crystals/shouldProcess()
	if( has_spread )
		return 0

	return 1


/atom/movable/cell/supermatter_crystals/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	health -= W.force

	if( health <= 0 )
		smash( prob( 100/smlevel ))

/atom/movable/cell/supermatter_crystals/proc/smash( var/drop = 0 )
	if(smlevel>=6 && prob(min(100, smlevel*10)))
		visible_message("\red <B>\The [src] explodes!</B>")
		playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
		supermatter_delamination( get_turf( src ), smlevel/2, smlevel, 0, 0 )
	else

		playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)

		for(var/mob/living/l in range( src, 2 ))
			var/rads = 15*smlevel
			l.apply_effect(rads, IRRADIATE)

		if( drop )
			visible_message("\red <B>\The [src] shatters!</B>")
			new /obj/item/weapon/shard/supermatter( get_turf( src ), smlevel )
		else
			visible_message("\red <B>\The [src] shatters to dust!</B>")

	qdel( src )

/atom/movable/cell/supermatter_crystals/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.containsCell( type ))
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