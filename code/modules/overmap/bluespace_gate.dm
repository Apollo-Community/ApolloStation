/obj/machinery/bluespace_inducer
	name = "bluespace inducer"
	desc = "A beacon used to warp to other sectors"
	icon = 'icons/rust.dmi'
	icon_state = "injector-emitting"
	density = 1
	opacity = 0
	anchored = 1
	unacidable = 1
	l_color = "#142933"
	var/brightness = 2
	var/functional = 1
	var/obj/effect/map/sector = null
	var/turf/exit = null

/obj/item/ray
	name = "Energy Ray"
	icon = 'icons/effects/beam.dmi'
	icon_state = "field"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	var/damage_type = BURN
	var/damage = 40
	var/active = 1
	var/obj/item/ray/child = null
	var/power = 20
	var/turf/neighbor = null // The next tile that the ray "moves" onto

	New(var/set_power = 20, dir = dir )
		power = set_power

		neighbor = get_step( src, dir )

		if( istype( neighbor, /turf/simulated/floor ) || istype( neighbor, /turf/space ))
			child = new(power-1, dir)

	process()
		if( !active )
			Del()
		if( child )
			return
		if( power <= 1 )
			return

		neighbor = get_step( src, dir )
		if( istype( neighbor, /turf/simulated/floor ) || istype( neighbor, /turf/space ))
			child = new(power-1, dir)
			return

		if( istype( neighbor, /turf/simulated/wall ))
			var/turf/simulated/wall/wall = neighbor
			wall.take_damage(damage)


	Del()
		if( child )
			del( child )


