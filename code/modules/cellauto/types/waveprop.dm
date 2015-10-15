/atom/movable/cell/v_wave
	name = "vorbis radiation"
	desc = "Vorbis radiation, don't breathe this!"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "vorbis_wave"

	age_max = 4

	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3

	color = SM_DEFAULT_COLOR
	master_type = /datum/cell_auto_master/v_wave

/atom/movable/cell/v_wave/process()
	if( age >= age_max )
		qdel(src)

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		for( var/direction in cardinal ) // Only gets NWSE
			var/turf/T = get_step( src,direction )
			if( checkTurf( T ))
				PoolOrNew( /atom/movable/cell/v_wave, list( T, master ))

/atom/movable/cell/v_wave/Destroy()
	if( master )
		master.cells -= src

	..()

/atom/movable/cell/v_wave/shouldProcess()
	if( age > 1 )
		return 0

	return 1

/atom/movable/cell/v_wave/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.autocell )
		return 0

	if( iswall( T ))
		return 0

	return 1

/datum/cell_auto_master/v_wave/New()
	..()

	v_wave_handler.masters += src

/datum/cell_auto_master/v_wave/Destroy()
	v_wave_handler.masters -= src

	..()