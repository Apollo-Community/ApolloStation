#define BLUESPACE_LEVEL 2

/obj/machinery/singularity/bluespace_gate
	name = "bluespace gate"
	desc = "A gate into the extradimensional space know as \"bluespace\"."
	icon = 'icons/effects/bluespace_gate.dmi'
	eat_turf = 0
	current_size = 3
	allowed_size = 3
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	event_chance = 0
	move_self = 0
	consume_range = 1
	pixel_x = -32
	pixel_y = -32
	l_color = "#142933"
	var/lifetime = 100
	var/decay = 10
	var/turf/exit = null

/obj/machinery/singularity/bluespace_gate/process()
	..()

	lifetime -= decay
	if( lifetime <= 0 )
		del(src)

/obj/machinery/singularity/bluespace_gate/New( loc, var/turf/new_exit )
	..(loc)

	exit = new_exit

	if( !exit )
		testing( "A bluespace gate was opened with no exit." )
	else
		testing( "A bluespace gate was opened with exit ([exit.x], [exit.y], [exit.z])" )
	l_color = "#142933"
	SetLuminosity( 5 )

/obj/machinery/singularity/bluespace_gate/consume(var/atom/A)
	if( !istype( A, /obj/machinery/gate_beacon ))
		bluespace_jump( src, A, exit )

/proc/bluespace_jump( var/turf/source, var/atom/A, var/turf/exit = null )
	if( !A ) return
	if( !source ) return

	var/x_off = source.x-A.x
	var/y_off = source.y-A.y

	var/turf/bluespace = locate( rand( OVERMAP_EDGE, world.maxx-OVERMAP_EDGE ), rand( OVERMAP_EDGE, world.maxy-OVERMAP_EDGE ), BLUESPACE_LEVEL )
	var/turf/destination

	// Getting the amount of time that the object will spend in bluespace
	var/transit_time = rand( 30, 80 )

	if( exit ) // Getting the destination
		destination = locate( exit.x-x_off, exit.y-y_off, exit.z ) // Getting the destination relative to where the object left
	else // If we don't have a destination, toss them somewhere random
		destination = locate( source.x+pick( rand( -10, source.x-2 ), rand( source.x+2, 10 )), source.y+pick( rand( -10, source.y-2 ), rand( source.y+2, 10 )), source.z )

	// Transporting turfs
	if( istype( A, /turf/simulated ) && !istype( A, /turf/simulated/floor/bspace_safe ))
		var/type = A.type
		var/turf/simulated/transmit = A
		transmit.ChangeTurf(/turf/space)

		spawn( transit_time )
			destination.ChangeTurf(type)
		return
	else if( istype( A, /turf ))
		return

	var/atom/movable/AM = A
	//testing( "Warping [AM] into bluespace from ([AM.x], [AM.y], [AM.z]). Expected arrival is ([destination.x], [destination.y], [destination.z])." )

	AM.loc = bluespace

	spawn( transit_time )
		if( !exit )
			if( istype( AM, /mob ))
				var/mob/M = AM
				M << "\red You feel that something went very wrong."

		AM.loc = destination