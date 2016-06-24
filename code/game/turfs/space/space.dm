/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	dynamic_lighting = 0
	plane = PLANE_SPACE_BACKGROUND

	temperature = 3
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	var/obj/effect/light_emitter/starlight/starlight = null
	var/overmap_transition = 0 // Do objects / mobs transit to the overmap on this turf?

//	heat_capacity = 700000 No.

/turf/space/New()
	icon_state = ""

	if(istype(src, /turf/space/bluespace))
		icon_state = "bluespace"

	var/state_roll = "[((x + y) ^ ~(x * y) + z) % 25]"
	if(!icon_state) // regular space
		icon_state = state_roll

	var/image/I = image('icons/turf/space_parallax1.dmi',"[state_roll]")
	I.plane = PLANE_SPACE_DUST
	I.alpha = 80
	I.blend_mode = BLEND_ADD
	overlays += I

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
		if( overmap_transition )
			A.overmapTravel()

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
		qdel(A)

	return