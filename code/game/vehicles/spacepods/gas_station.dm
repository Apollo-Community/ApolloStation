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
	..()

	processing_objects.Add( src )
	spawn( 30 )
		init_devices()
		hose = new /datum/global_iterator/refueling_floor( list( src ))

/turf/simulated/floor/bspace_safe/refueling_floor/Del()
	processing_objects.Remove( src )
	del( hose )

	..()

/turf/simulated/floor/bspace_safe/refueling_floor/Entered( var/obj/spacepod/spacepod )
	. = ..()

	init_devices( spacepod )

	return

/turf/simulated/floor/bspace_safe/refueling_floor/Exited(atom)
	. = ..()
	if( atom == refueling )
		refueling = null
		sync_devices()
	return

/turf/simulated/floor/bspace_safe/refueling_floor/proc/init_devices( var/obj/spacepod/spacepod = null )
	for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in range( src, 3 ))
		testing( "Fuel tank found" )
		fuel_tanks.Add( tank )

	for( var/turf/simulated/floor/bspace_safe/refueling_floor/port in range( src, 3 ))
		testing( "Fuel port found" )
		fuel_ports.Add( port )

	if( !spacepod ) // If we weren't given one, we better find one
		for( spacepod in range( src, 1 ))
			testing( "Spacepod found" )
			break

	if( !istype( spacepod )) // If we still couldn't find one, lets end this hopeless endeavour
		testing( "Not a valid spacepod" )
		return

	if( spacepod == refueling )
		testing( "Already matches the spacepod being refueled" )
		return

	spacepod.occupants_announce("Connecting pod to refueling station...")

	if( spacepod.equipment_system.engine_system )
		if( fuel_tanks.len >= 1 ) // if we have a tank to take fuel from
			refueling = spacepod
			refueling.occupants_announce("Connected to refueling station.")
			sync_devices()
		else
			spacepod.occupants_announce("No nearby tanks to refuel from!", 2)
	else
		spacepod.occupants_announce("This spacepod does not have an engine!", 2)

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
	if( hose )
		if( hose.refueling )
			for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in hose.fuel_tanks )
				var/obj/spacepod/refueling = hose.refueling
				var/datum/gas_mixture/pod = refueling.equipment_system.engine_system.fuel_tank
				var/datum/gas_mixture/fuel = tank.air_temporary
				var/pressure_delta
				var/output_volume
				var/air_temperature
				var/target_pressure = 10*ONE_ATMOSPHERE // max pressure of the fuel tank

				pressure_delta = target_pressure-pod.return_pressure()
				output_volume = pod.volume/4.0
				air_temperature = fuel.temperature? fuel.temperature : pod.temperature
	/*
				testing( "Pressure delta: [pressure_delta]" )
				testing( "Output volume: [output_volume]" )
				testing( "Air temperature: [air_temperature]" )
	*/
				var/transfer_moles = pressure_delta*output_volume/(air_temperature * R_IDEAL_GAS_EQUATION)
	//			testing( "Calculated trasnfer moles: [transfer_moles]" )

				if (isnull(transfer_moles))
					transfer_moles = fuel.total_moles
				else
					transfer_moles = min(fuel.total_moles, transfer_moles)

		/*
					if(fuel)
						testing( "Fuel exists and has [fuel.total_moles] mols of gas in it" )
					else
						testing( "Fuel does not exist" )
		*/

	//			testing( "Attempting to merge [transfer_moles] of gas." )
				var/datum/gas_mixture/removed = fuel.remove(transfer_moles)
				if (removed) //Just in case
	//				testing( "Gas succesfully merged!" )
					pod.merge(removed)
				else
	//				testing( "Failed to remove gas!" )
					return -1
	//	else
	//		testing( "No spacepod located!" )

