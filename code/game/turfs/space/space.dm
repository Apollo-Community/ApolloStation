/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = ""
	dynamic_lighting = 0
	plane = SPACE_PARALLAX_PLANE - 1

	temperature = 3
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	var/obj/effect/light_emitter/starlight/starlight = null
//	heat_capacity = 700000 No.

/turf/space/New()
	/*
	if(!istype(src, /turf/space/transit) && !istype(src, /turf/space/bluespace))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	*/

	update_starlight()

/turf/space/proc/update_starlight()
	if(!config.starlight)
		return
	if( !starlight )
		if( locate( /turf/simulated ) in orange( src, 1 ))
			starlight = new /obj/effect/light_emitter/starlight( src )

/obj/effect/light_emitter/starlight
	name = ""
	desc = ""
	light_range = 2

/obj/effect/light_emitter/starlight/New()
	light_range = rand( 2, 3 )
	..()

/turf/space/Destroy()
	..()

	qdel( starlight )

/turf/space/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		var/obj/item/stack/rods/R = C
		if (R.use(1))
			user << "<span class='notice'>Constructing support lattice ...</span>"
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		return

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if (S.get_amount() < 1)
				return
			qdel(L)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			S.use(1)
			return
		else
			user << "<span class='alert'>The plating is going to need some support.</span>"
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	if(movement_disabled)
		usr << "<span class='alert'>Movement is admin-disabled.</span>" //This is to identify lag problems
		return

	..()

	if ((!(A) || src != A.loc))	return

	inertial_drift(A)

	if(ticker && ticker.mode)
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			A.overmapTravel()

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
		qdel(A)

	return