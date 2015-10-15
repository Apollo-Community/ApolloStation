/atom/movable/cell/v_wave
	name = "vorbis radiation"
	desc = "Vorbis radiation, don't breathe this!"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "vorbis_wave"

	age_max = 3
/*
	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3
*/

	color = SM_DEFAULT_COLOR

/atom/movable/cell/v_wave/New( loc as turf, var/direction = 1 )
	..()

	dir = direction
	v_wave_handler.cells += src

/atom/movable/cell/v_wave/process()
	if( age >= age_max )
		qdel(src)

	if( !age ) // If we have not aged at all
		for( var/turf/T in orange( 1, get_turf( src )))
			if( vwaveCanExpand( T ))
				PoolOrNew( /atom/movable/cell/v_wave, T )

	age++

	..()

/atom/movable/cell/v_wave/Destroy()
	v_wave_handler.cells -= src

	..()

/proc/vwaveCanExpand( var/turf/T )
	if( !T )
		return 0

	if( T.autocell )
		return 0

	if( iswall( T ))
		return 0

	return 1