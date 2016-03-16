/obj/machinery/floor/refueling_floor
	name = "Refueling floor"
	desc = "It has little hoses that come out of the floor when a spacepod hovers over top of them."
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	var/list/fuel_tanks = list()
	var/list/fuel_ports = list()
	var/obj/spacepod/refueling = null

/obj/machinery/floor/refueling_floor/New()
	..()

	spawn( 30 )
		init_devices()

/obj/machinery/floor/refueling_floor/Destroy()
	..()

/obj/machinery/floor/refueling_floor/Crossed( var/obj/spacepod/spacepod )
	. = ..()

	init_devices( spacepod )

	return

/obj/machinery/floor/refueling_floor/Uncrossed(atom)
	. = ..()
	if( atom == refueling )
		refueling = null
		sync_devices()
	return

/obj/machinery/floor/refueling_floor/proc/init_devices( var/obj/spacepod/spacepod = null )
	for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in range( src, 3 ))
		fuel_tanks.Add( tank )

	for( var/obj/machinery/floor/refueling_floor/port in range( src, 3 ))
		fuel_ports.Add( port )

	if( !spacepod ) // If we weren't given one, we better find one
		for( spacepod in range( src, 1 ))
			break

	if( !istype( spacepod )) // If we still couldn't find one, lets end this hopeless endeavour
		return

	if( spacepod == refueling )
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

/obj/machinery/floor/refueling_floor/proc/sync_devices()
	for( var/obj/machinery/floor/refueling_floor/port in fuel_ports )
		port.refueling = src.refueling
		port.fuel_ports = src.fuel_ports
		port.fuel_tanks = src.fuel_tanks

/obj/machinery/floor/refueling_floor/process()
	if( !refueling )
		return

	if( !refueling.equipment_system.engine_system )
		return

	var/datum/gas_mixture/pod = refueling.equipment_system.engine_system.fuel_tank

	for( var/obj/machinery/atmospherics/pipe/tank/phoron/tank in fuel_tanks )
		var/datum/gas_mixture/fuel = tank.air_temporary
		var/pressure_delta
		var/output_volume
		var/air_temperature
		var/target_pressure = refueling.equipment_system.engine_system.max_pressure // max pressure of the fuel tank

		pressure_delta = target_pressure-pod.return_pressure()
		output_volume = pod.volume/16.0
		air_temperature = fuel.temperature? fuel.temperature : pod.temperature

		var/transfer_moles = pressure_delta*output_volume/(air_temperature * R_IDEAL_GAS_EQUATION)

		if (isnull(transfer_moles))
			transfer_moles = fuel.total_moles
		else
			transfer_moles = min(fuel.total_moles, transfer_moles)

		var/datum/gas_mixture/removed = fuel.remove(transfer_moles)
		if (removed) //Just in case
			pod.merge(removed)
		else
			return -1
