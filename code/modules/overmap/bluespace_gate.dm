#define BLUESPACE_LEVEL 8

/obj/machinery/singularity/bluespace_gate
	name = "bluespace gate"
	desc = "A gate into the extradimensional space know as \"bluespace\"."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "emfield_s3"
	eat_turf = 0
	life = 100
	grav_pull = 3
	event_chance = 0
	move_self = 0
	consume_range = 1
	var/turf/exit = null

/obj/machinery/singularity/bluespace_gate/New( exit = exit )
	..()

/obj/machinery/singularity/bluespace_gate/consume(var/atom/A)
	if( !istype( A, /obj/machinery/gate_beacon ))
		warp( src, A )


/obj/machinery/singularity/bluespace_gate/proc/warp( var/turf/source, var/atom/A )
	var/x_off = source.x-A.x
	var/y_off = source.y-A.y

	var/turf/bluespace = locate( rand( OVERMAP_EDGE, world.maxx-OVERMAP_EDGE ), rand( OVERMAP_EDGE, world.maxy-OVERMAP_EDGE ), BLUESPACE_LEVEL )
	var/turf/initial = A.loc
	var/turf/destination

	// Getting the destination
	if( exit )
		destination = locate( exit.x+x_off, exit.y+y_off, exit.z ) // Getting the destination relative to where the object left
	else
		destination = initial

	// Transporting turfs
	if( istype( A, /turf/ ))
		var/type = A.type
		var/turf/transmit = A
		transmit.ChangeTurf(/turf/space)

		spawn( rand( 50, 100 ))
			destination.ChangeTurf(type)

	var/atom/movable/AM = A
	AM.loc = bluespace
	spawn( rand( 110, 150 ))
		if( destination == initial )
			if( istype( AM, /mob/ ))
				AM << "\red You feel that something went wrong."

		AM.loc = destination