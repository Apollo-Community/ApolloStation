/obj/structure/spacepoddoor
	name = "energy barrier"
	desc = "A a repulsive energy field that only allows pods to pass."
	icon = 'icons/effects/beam.dmi'
	icon_state = "field"
	var/id = 1.0
	density = 0
	anchored = 1

	New() //set the turf below the flaps to block air
		var/turf/T = get_turf(loc)

		light_color = "#66FFFF"
		light_range = 3

		if(T)
			T.blocks_air = 1
		..()

	Destroy() //lazy hack to set the turf to allow air to pass if it's a simulated floor
		var/turf/T = get_turf(loc)
		if(T)
			if(istype(T, /turf/simulated/floor))
				T.blocks_air = 0
		..()



/obj/structure/spacepoddoor/CanPass(atom/A, turf/T)
	if(istype(A, /obj/spacepod))
		return ..()
	else return 0

