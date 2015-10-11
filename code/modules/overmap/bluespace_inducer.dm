/obj/machinery/power/bluespace_inducer
	name = "bluespace inducer"
	desc = "A device used to increased instability in the bluespace matrix, opening temporary holes from our reality into the extradimension."
	icon = 'icons/rust.dmi'
	icon_state = "injector-open"
	density = 1
	opacity = 0
	anchored = 1
	unacidable = 1
	light_color = "#142933"
	use_power = 0	//uses powernet power, not APC power
	active_power_usage = 10	// 100kW per inducer, so opening a bluespace gate costs 400kW in total, better hope those engineers deliver

	var/brightness = 2
	var/functional = 1
	var/obj/machinery/gate_beacon/beacon = null
	var/max_beacon_dist = 5 // The maximum distance that the beacon can be from the inducer
	var/active = 0
	var/charge_rate = 25 // The rate that the inducer charges the beacon

/obj/machinery/power/bluespace_inducer/New()
	spawn( 25 )
		if( !find_beacon() )
			return 0

	..()


/obj/machinery/power/bluespace_inducer/Destroy()
	if( beacon )
		beacon.inducers.Remove( src )

	..()

/obj/machinery/power/bluespace_inducer/update_icon()
	light_color = "#142933"
	if (active && powernet && avail(active_power_usage))
		icon_state = "injector-emitting"
		set_light( brightness )
	else
		icon_state = "injector-open"
		set_light( 0 )

/obj/machinery/power/bluespace_inducer/process()
	if( active )
		beacon.charge( charge_rate )
/*		var/actual_load = draw_power(active_power_usage)
		if( actual_load >= active_power_usage )

		else
			deactivate()
*/w

/obj/machinery/power/bluespace_inducer/proc/find_beacon()
	var/turf/cur_turf = src
	for( var/distance=1, distance<=max_beacon_dist, distance++ )
		cur_turf = get_step( cur_turf, dir )

		for( beacon in cur_turf )
			break
		if( beacon )
			beacon.inducers.Add( src )
			functional = 1
			return 1

	if( !beacon )
		functional = 0
		return 0

/obj/machinery/power/bluespace_inducer/proc/activate( beacon = beacon )
	if( !beacon )
		if( !find_beacon() )
			src.ping("[src] states, \"ERROR: Cannot find beacon!\"")
			return
	active = 1

	update_icon()


/obj/machinery/power/bluespace_inducer/proc/deactivate()
	active = 0

	update_icon()

/*
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
			child = new(power-1, dir, neighbor )

	process()
		if( !active )
			Destroy()
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


	Destroy()
		if( child )
			qdel( child )
*/

