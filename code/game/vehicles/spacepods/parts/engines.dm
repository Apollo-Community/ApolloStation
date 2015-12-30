
/obj/item/device/spacepod_equipment/engine
	name = "PutPut (engine)"
	desc = "An extremely basic, but cheap, engine."
	icon_state = "engine"
	var/datum/gas_mixture/fuel_tank = null
	var/max_pressure = 10*ONE_ATMOSPHERE // standard pressure
	var/volume = 300.000

	var/burn_rate = 0.20 // 0.2 mols per meter, starter engine is total carp efficiency
	var/heat_rate = 10 // how much heat is gained per meter moved
	var/heat_rad_rate = 10 // how much heat is radiated per tick
	var/max_temp = 400 // how hot this baby can get before bad things happen
	var/fire_heat = 20 // how much heat fire causes

	var/fire = 0 // are we on fire right now?

	var/charge_rate = 10 // how much energy is generated every time fuel is used

	var/use_fuel = 1 // whether this engine runs on fuel or a nice hot cup of tea

	var/ticks_per_move = 5 // toot toot, how many ticks it takes to move a single tile
	var/move_tick = 0 // Keeps track of how many ticks its been since we last moved

/obj/item/device/spacepod_equipment/engine/New()
	..()

	src.fuel_tank = new /datum/gas_mixture()
	src.fuel_tank.volume = volume //liters
	src.fuel_tank.temperature = T20C

	spawn( 30 )
		processing_objects.Add( src )

/obj/item/device/spacepod_equipment/engine/Destroy()
	processing_objects.Remove( src )

	..()

/obj/item/device/spacepod_equipment/engine/process()
	var/temp_fire = fire

	if( fire )
		if( prob( 2 )) // Fires have a small chance of putting themselves out
			fire = 0
		else
			fire = 1
	if( fuel_tank.temperature >= max_temp )
		fire = 1

	if( my_atom )
		if( my_atom.fire_hazard() )
			if( prob( 10 )) // if the pod is damage enough, there is a chance of fire
				fire = 1

		if( fire != temp_fire )
			my_atom.update_icon()

		if( fuel_tank.temperature >= max_temp ) // hurt em a bit for running it too hot
			my_atom.deal_damage(( fuel_tank.temperature/( 4*max_temp ))*heat_rate )

		if( my_atom.pilot )
			my_atom.update_HUD( my_atom.pilot )

	if( fire ) // If we agree that we're on fire, light em up
		fuel_tank.add_thermal_energy( fire_heat )

	fuel_tank.add_thermal_energy( -heat_rad_rate )

/obj/item/device/spacepod_equipment/engine/check()
	if( fuel_tank.total_moles > 0 )
		return 1
	else
		return 0

// Runs a single cycle of the engine
/obj/item/device/spacepod_equipment/engine/proc/cycle( var/iterations = 1 )
	if( move_tick < ticks_per_move )
		move_tick++
		return 0

	move_tick = 0

	for( var/i = 0, i<iterations, i++ )
		if( use_fuel )
			if( fuel_tank.gas["phoron"] > 0 )
				fuel_tank.adjust_gas( "phoron", -burn_rate) // use up dat phoron
				fuel_tank.add_thermal_energy(heat_rate) // heat from the engine using phoron

				if( my_atom.equipment_system.battery ) // charge the battery if we have one
					my_atom.equipment_system.battery.give( charge_rate )

				if( fuel_tank.gas["oxygen"] > 0 )
					fuel_tank.adjust_gas( "oxygen", -burn_rate/2) // burn up oxygen at half rate 4noraisin
					fuel_tank.add_thermal_energy(heat_rate*10) // putting oxygen in this baby is bad news

					if( my_atom.equipment_system.battery ) // but hey, we'll charge the battery even faster
						my_atom.equipment_system.battery.give( charge_rate*2 )
			else
				my_atom.occupants_announce( "ERROR: No phoron left in the fuel tank!", 2 )
				return 0

	return 1

/obj/item/device/spacepod_equipment/engine/proc/fill( var/obj/item/weapon/tank/tank )
	if( !tank )
		usr << "That's not a valid tank!"
		return 0

	for( var/G in tank.air_contents.gas )
		world << G
		if( G == "phoron" && tank.air_contents.gas[G] > 0 )
			fuel_tank.adjust_gas( "phoron", tank.air_contents.gas[G] )
			tank.air_contents.adjust_gas( "phoron", -tank.air_contents.gas[G] )
			playsound( get_turf( my_atom ), 'sound/machines/hiss.ogg', 50, 1 )
			usr << "You hook the gas tank up to the fuel hose and with a hiss all of the phoron is added to the pod's fuel tank."
			return 1
		else
			usr << "There's no phoron gas in that tank!"
			return 0

/obj/item/device/spacepod_equipment/engine/proc/get_temp()
	return fuel_tank.temperature

/*====== MAGICAL DEV ENGINE =========*/
/obj/item/device/spacepod_equipment/engine/magic
	use_fuel = 0
	ticks_per_move = 1

/*====== Engines manufactured by the Newton Engines corporation =========*/
/obj/item/device/spacepod_equipment/engine/einstein
	manufacturer = "Einstein Engines"

/obj/item/device/spacepod_equipment/engine/einstein/galileo
	name = "Galileo 2560 (engine)"
	desc = "A top-of-the-line engine in both efficiency and speed, but lacking in tank size."
	burn_rate = 0.018
	max_pressure = 10*ONE_ATMOSPHERE
	volume = 50.000
	ticks_per_move = 1
	charge_rate = 15

/obj/item/device/spacepod_equipment/engine/einstein/fourier
	name = "Fourier J3 (engine)"
	desc = "An engine great for transport, but because of its low electrical output, it is not recommended for military ships."
	burn_rate = 0.005
	max_pressure = 10*ONE_ATMOSPHERE
	volume = 150.000
	ticks_per_move = 4
	charge_rate = 1