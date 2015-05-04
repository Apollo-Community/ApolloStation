/turf/simulated/floor/bspace_safe/refueling_floor
	name = "Refueling floor"
	desc = "It has little hoses that come out of the floor when a spacepod hovers over top of them."
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	var/list/fuel_tanks = list()
	var/list/fuel_ports = list()
	var/obj/spacepod/refueling = null
	var/datum/global_iterator/refueling_floor/hose

/turf/simulated/floor/bspace_safe/refueling_floor/New()
	processing_objects.Add( src )

	hose = new /datum/global_iterator/refueling_floor( null, 0 )

	..()

/turf/simulated/floor/bspace_safe/refueling_floor/Del()
	processing_objects.Remove( src )
	..()

/turf/simulated/floor/bspace_safe/refueling_floor/Entered( var/obj/spacepod/spacepod )
	. = ..()
	if( spacepod == refueling )
		return

	if( istype( spacepod ))
		spacepod.occupants_announce("Connecting pod to refueling station...")
		init_devices()

		if( spacepod.equipment_system.engine_system )
			if( fuel_tanks.len >= 1 ) // if we have a tank to take fuel from
				refueling = spacepod
				refueling.occupants_announce("Connected to refueling station.")
				sync_devices()
				hose.start( src )
			else
				spacepod.occupants_announce("No nearby tanks to refuel from!", 2)
		else
			spacepod.occupants_announce("This spacepod does not have an engine!", 2)

	return

/turf/simulated/floor/bspace_safe/refueling_floor/Exited(atom)
	. = ..()
	if( atom == refueling )
		refueling = null
		hose.stop()
		sync_devices()
	return

/turf/simulated/floor/bspace_safe/refueling_floor/proc/init_devices()
	for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in range( src.loc, 3 ))
		fuel_tanks.Add( tank )

	for( var/turf/simulated/floor/bspace_safe/refueling_floor/port in range( src.loc, 3 ))
		fuel_ports.Add( port )

	return

/turf/simulated/floor/bspace_safe/refueling_floor/proc/sync_devices()
	for( var/turf/simulated/floor/bspace_safe/refueling_floor/port in fuel_ports )
		port.refueling = src.refueling
		port.fuel_ports = src.fuel_ports
		port.fuel_tanks = src.fuel_tanks
		port.hose = src.hose

/datum/global_iterator/refueling_floor
	delay = 20
	check_for_null = 0

/datum/global_iterator/refueling_floor/process( var/turf/simulated/floor/bspace_safe/refueling_floor/hose )
	if( hose.refueling )
		for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in hose.fuel_tanks )
			var/datum/gas_mixture/fuel = tank.air_temporary
			var/obj/spacepod/refueling = hose.refueling
			var/datum/gas_mixture/pod = refueling.equipment_system.engine_system.fuel_tank

			var/transfer_moles = 0.003 * fuel.total_moles
			var/datum/gas_mixture/removed = fuel.remove( transfer_moles )

			if(removed)
				if( !pod.merge( removed ))
					testing( "Could not get merge the gas" )
					src.stop()
			else
				testing( "Could not get transfer gas" )
