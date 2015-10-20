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

	var/has_spread = 0
	var/health = 30

/atom/movable/cell/supermatter_crystals/New()
	..()

	spawn(0)
		update_icon()

/atom/movable/cell/supermatter_crystals/proc/update_icon()
	if( iswall( get_turf( src )))
		icon_state = "wall_crystal"
	else
		icon_state = "floor_crystal"
		density = 1

	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		color = getSMVar( M.smlevel, "color" )
		light_color = color

		name = getSMVar( M.smlevel, "color_name" ) + " " + initial(name)

		set_light( light_range, light_power, light_color )


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
	has_spread = 1

	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			if( prob( 40 ))
				PoolOrNew( /atom/movable/cell/supermatter_crystals, list( T, master ))

/atom/movable/cell/supermatter_crystals/proc/radiate()
	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		for(var/mob/living/l in range( src, M.smlevel ))
			var/rads = M.smlevel*5
			l.apply_effect(rads, IRRADIATE)

/atom/movable/cell/supermatter_crystals/shouldProcess()
	if( has_spread )
		return 0

	return 1


/atom/movable/cell/supermatter_crystals/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	health -= W.force

	if( health <= 0 )
		if( master )
			var/datum/cell_auto_master/v_wave/M = master
			smash( prob( 100-( 10*M.smlevel ))) // the highest the level, the less likely you are to get a crystal dropped

/atom/movable/cell/supermatter_crystals/ex_act(severity)
	switch(severity)
		if(1.0)
			smash()
			return
		if(2.0)
			if (prob(90))
				smash()
				return
		if(3.0)
			if (prob(50))
				smash()
				return
	return

/atom/movable/cell/supermatter_crystals/bullet_act(var/obj/item/projectile/P)
	..()

	health -= P.damage

	if( health <= 0 )
		if( master )
			var/datum/cell_auto_master/v_wave/M = master
			smash( prob( 30/M.smlevel )) // the higher the level, the less likely you are to get a crystal dropped

/atom/movable/cell/supermatter_crystals/proc/smash( var/drop = 0 )
	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		if( M.smlevel >= 4 && prob( min( 100, M.smlevel*10 )))
			visible_message("\red <B>\The [src] explodes!</B>")
			playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
			supermatter_delamination( get_turf( src ), M.smlevel/2, M.smlevel, 0, 0 )
		else
			playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)

			for(var/mob/living/l in range( src, 2 ))
				var/rads = 15*M.smlevel
				l.apply_effect(rads, IRRADIATE)

			if( drop )
				visible_message("\red <B>\The [src] shatters!</B>")
				new /obj/item/weapon/shard/supermatter( get_turf( src ), M.smlevel )
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