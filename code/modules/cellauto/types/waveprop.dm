/atom/movable/cell/v_wave
	name = "vorbis radiation"
	desc = "Vorbis radiation, don't breathe this!"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "vorbis_wave"

	age_max = 2

	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3

	color = SM_DEFAULT_COLOR
	master_type = /datum/cell_auto_master/v_wave

/atom/movable/cell/v_wave/New()
	..()

	update_icon()

/atom/movable/cell/v_wave/proc/update_icon()
	..()

	if( master )
		var/datum/cell_auto_master/v_wave/M = master

		color = getSMVar( M.smlevel, "color" )
		light_color = color

		set_light( light_range, light_power, light_color )

/atom/movable/cell/v_wave/process()
	if( shouldDie() )
		qdel(src)

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		spread()
		convert()

/atom/movable/cell/v_wave/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/v_wave, list( T, master ))

/atom/movable/cell/v_wave/proc/convert()
	var/datum/cell_auto_master/v_wave/M = master

	supermatter_convert( get_turf( src ), 1, M.smlevel )

/atom/movable/cell/v_wave/shouldProcess()
	if( age > 1 )
		return 0

	return 1

/atom/movable/cell/v_wave/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.containsCell( type ))
		return 0

	if( istype( T, /turf/simulated/wall/r_wall ))
		return 0

	if( T.contains_opaque_objects() && level == 1 )
		return 0

	return 1


/datum/cell_auto_master/v_wave/
	var/smlevel = 1
	cell_type = /atom/movable/cell/v_wave

/datum/cell_auto_master/v_wave/New( var/loc as turf, size = 0, var/level = 0 )
	..()

	if( level )
		smlevel = level

	v_wave_handler.masters += src

/datum/cell_auto_master/v_wave/Destroy()
	v_wave_handler.masters -= src

	..()