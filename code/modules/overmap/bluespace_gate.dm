#define BLUESPACE_LEVEL 2

/obj/singularity/bluespace_gate
	name = "bluespace gate"
	desc = "A gate into the extradimensional space know as \"bluespace\"."
	icon = 'icons/effects/bluespace_gate.dmi'
	eat_turf = 0
	current_size = 3
	allowed_size = 3
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	dissipate_strength = 0
	event_chance = 0
	move_self = 0
	consume_range = 1
	pixel_x = -32
	pixel_y = -32
	light_color = "#142933"
	temp = 100
	var/decay = 10
	var/turf/exit = null

/obj/singularity/bluespace_gate/process()
	eat()

	if(prob(1))
		mezzer()

/obj/singularity/bluespace_gate/New( loc, var/new_exit )
	..(loc)

	exit = new_exit

	light_color = "#142933"
	set_light( 5 )

/obj/singularity/bluespace_gate/consume(var/atom/A)
	if( !istype( A, /obj/machinery/gate_beacon ))
		bluespace_jump( src, A, exit )

/proc/bluespace_jump( var/turf/source, var/atom/A, var/turf/exit = null )
	if( !A ) return
	if( !source ) return
	if( istype( A, /turf )) return // turfs can't go through
	if( istype( A, /atom/movable/lighting_overlay )) return  // dont want to take our lighting overlays

	if( istype( A, /obj ) && !istype( A, /obj/spacepod/shuttle )) // anything nailed down can't go through
		var/obj/O = A
		if( O.anchored )
			return

	var/turf/A_turf = get_turf( A )
	var/x_off = source.x-A_turf.x
	var/y_off = source.y-A_turf.y

	var/area/bspace = locate( /area/space/bluespace )
	var/turf/bluespace = pick( get_area_turfs( bspace ))

//	var/turf/bluespace = locate( rand( OVERMAP_EDGE, world.maxx-OVERMAP_EDGE ), rand( OVERMAP_EDGE, world.maxy-OVERMAP_EDGE ), BLUESPACE_LEVEL )
	var/turf/destination

	// Getting the amount of time that the object will spend in bluespace
	var/transit_time = rand( 60, 120 )

	if( istype( exit )) // Getting the destination
		destination = locate( exit.x-x_off, exit.y-y_off, exit.z ) // Getting the destination relative to where the object left
	else // If we don't have a destination, toss them somewhere random
		var/exit_x = rand( source.x-20, source.x+20 )
		var/exit_y = rand( source.y-20, source.y+20 )
		var/exit_z = pick( config.can_random_teleport_levels )

		destination = locate( exit_x, exit_y, exit_z )

	if( !destination )
		return

/*
	animate(A, transform = matrix()*(-2), transform = turn(matrix(), 360), time = 2)
	sleep(2)
	animate(A, transform = null, time = 1)
*/

	var/atom/movable/AM = A

	AM.forceMove( bluespace )

	spawn( transit_time )
		if( !exit )
			if( istype( AM, /mob ))
				var/mob/M = AM
				M << "<span class='alert'>You feel that something went very wrong.</span>"

		AM.forceMove( destination )
		playsound(AM.loc, 'sound/effects/pop1.ogg', 80, 1)