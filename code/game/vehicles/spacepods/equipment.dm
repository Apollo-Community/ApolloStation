/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()
	if(my_atom.next_firetime > world.time)
		usr << "<span class='warning'>Your weapons are recharging.</span>"
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		usr << "<span class='warning'>Missing equipment or weapons.</span>"
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return
	if( my_atom.equipment_system.battery )
		if( my_atom.equipment_system.battery.use(shot_cost) )
			usr << "There's not enough charge left!"
	else
		usr << "There's no battery in the system!"

	var/olddir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					firstloc = get_step(firstloc, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_step(my_atom, SOUTH)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					firstloc = get_step(firstloc, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_step(my_atom, WEST)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/proj_type = text2path(projectile_type)
		var/obj/item/projectile/projone = new proj_type(firstloc)
		var/obj/item/projectile/projtwo = new proj_type(secondloc)
		projone.starting = get_turf(my_atom)
		projone.shot_from = src
		projone.firer = usr
		projone.def_zone = "chest"
		projtwo.starting = get_turf(my_atom)
		projtwo.shot_from = src
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		spawn()
			playsound(src, fire_sound, 50, 1)
			projone.dumbfire(my_atom.dir)
			projtwo.dumbfire(my_atom.dir)
		sleep(2)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/list/spacepod_equipment = list()
	var/max_size = 5

	// Various systems for fast retrieval
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system  // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system
	var/obj/item/weapon/cell/battery // the battery, durh
	var/obj/item/pod_parts/armor/armor // what kind of armor it has
	var/obj/item/device/spacepod_equipment/misc/autopilot/autopilot // the autopilot

/datum/spacepod/equipment/New(var/obj/spacepod/SP, max_size)
	..()
	if(istype(SP))
		my_atom = SP

/datum/spacepod/equipment/proc/equip(var/obj/item/equipment, var/mob/user = null)
	if( spacepod_equipment.len < max_size )
		if( assign_system( equipment )) // Adding the special systems
			spacepod_equipment.Add( equipment )
			if( user )
				user << "<span class='notice'>You insert \the [equipment] into the equipment system.</span>"
				user.drop_item(equipment)
			equipment.loc = src
			my_atom.update_icons()
			return 1
		else
			if( user )
				user << "\red Could not add [equipment] to the [my_atom]."
			return 0
	else
		if( user )
			user << "\red There's no space left for the [equipment]!"
		return 0

/datum/spacepod/equipment/proc/dequip(var/obj/item/equipment, var/mob/user)
	if( user.put_in_any_hand_if_possible(equipment))
		user << "<span class='notice'>You remove \the [equipment] from the space pod</span>"
		deassign_system( equipment )
		spacepod_equipment.Remove( equipment )
		my_atom.update_icons()
		return 1
	else
		user << "<span class='notice'>You can't remove the [equipment]!</span>"

	return 0

// Assigns proper systems
/datum/spacepod/equipment/proc/assign_system(var/obj/item/equipment)
	if(istype( equipment, /obj/item/device/spacepod_equipment/weaponry )) // Assigning the weapon system
		weapon_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/engine )) // Assigning the engine system
		if( engine_system )
			return 0
		engine_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/shield )) // Assigning the shield system
		if( shield_system )
			return 0
		shield_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/misc/autopilot )) // Assigning the shield system
		if( autopilot )
			return 0
		autopilot = equipment
	else if( istype( equipment, /obj/item/device/spacepod_equipment/misc )) // Assigning misc systems
		misc_system = equipment
	else if( istype( equipment, /obj/item/weapon/cell )) // Assigning the battery
		if( battery )
			return 0
		battery = equipment
	else if(istype( equipment, /obj/item/pod_parts/armor ))
		if( armor )
			return 0
		armor = equipment

		if( istype( equipment, /obj/item/pod_parts/armor/command ))
			my_atom.health = 250
		else if( istype( equipment, /obj/item/pod_parts/armor/security ))
			my_atom.health = 400
		else
			my_atom.health = 100
	else if(!istype( equipment, /obj/item/device/spacepod_equipment ))  // If it wasn't any of those systems, and isn't spacepod_equipment, we don't want what you're selling
		return 0

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.assign(src.my_atom)

	return 1

// Deassigns proper system
/datum/spacepod/equipment/proc/deassign_system(var/obj/item/equipment)
	if( equipment == weapon_system ) // Assigning the weapon system
		weapon_system = null
	else if( equipment == misc_system ) // Assigning misc systems
		misc_system = null
	else if( equipment == engine_system ) // Assigning the engine system
		engine_system = null
	else if( equipment == shield_system ) // Assigning the shield system
		shield_system = null
	else if( equipment == autopilot ) // Assigning the battery
		autopilot = null
	else if( equipment == battery ) // Assigning the battery
		battery = null
	else if( equipment == armor )
		armor = null
		my_atom.health = 100
	else if(!istype( equipment, /obj/item/device/spacepod_equipment ))  // If it wasn't any of those systems, and isn't spacepod_equipment, we don't want what you're selling
		world << "MAH EMULSION: Tried to remove an impossible object from the spacepod, yell at Kwask."
		return 0

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.deassign()

	return 1

/datum/spacepod/equipment/proc/fill_engine( var/obj/item/weapon/tank/tank )
	if( engine_system )
		return engine_system.fill( tank )
	else
		usr << "There's no engine installed!"
		return 0

/obj/item/device/spacepod_equipment
	name = "equipment"
	icon = 'icons/pods/pod_parts.dmi'
	var/obj/spacepod/my_atom = null
	var/manufacturer = "NanoTrasen" // purely a fluff detail

/obj/item/device/spacepod_equipment/proc/check() // checks the status of a piece of equipment
	return 1

/obj/item/device/spacepod_equipment/proc/assign(var/obj/spacepod/atom)
	src.my_atom = atom

/obj/item/device/spacepod_equipment/proc/deassign()
	src.my_atom = null

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon_state = "blank"
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 20

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "\improper taser system"
	desc = "A weak taser system for space pods, fires electrodes that shock upon impact."
	icon_state = "pod_taser"
	projectile_type = "/obj/item/projectile/beam/disabler"
	shot_cost = 250
	fire_sound = "sound/weapons/Taser.ogg"

/obj/item/device/spacepod_equipment/weaponry/burst_taser
	name = "\improper burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/disabler"
	shot_cost = 350
	shots_per = 3
	fire_sound = "sound/weapons/Taser.ogg"
	fire_delay = 40

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "\improper laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy"
	icon_state = "pod_w_laser"
	projectile_type = "/obj/item/projectile/beam"
	shot_cost = 300
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 30

//base item for spacepod misc equipment (tracker)
/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/check()
	return enabled

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(check())
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = 1
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()

/obj/item/device/spacepod_equipment/engine
	name = "\improper spacepod engine"
	desc = "Vroom vroom."
	icon_state = "engine"
	var/datum/gas_mixture/fuel_tank = null
	var/max_volume = 112.000 // 112 mols, or 4 full tanks of phoron
	var/burn_rate = 0.050 // 0.1 mols per meter
	var/heat_rate = 10 // how much heat is gained per meter moved
	var/heat_rad_rate = 10 // how much heat is radiated per tick
	var/max_temp = 400 // how hot this baby can get before bad things happen
	var/charge_rate = 10 // how much energy is generated every time fuel is used
	var/use_fuel = 1 // whether this engine runs on fuel or a nice hot cup of tea
	var/fire_heat = 20 // how much heat fire causes
	var/fire = 0 // are we on fire right now?

/obj/item/device/spacepod_equipment/engine/New()
	..()

	src.fuel_tank = new /datum/gas_mixture()
	src.fuel_tank.volume = max_volume //liters
	src.fuel_tank.temperature = T20C

	spawn( 30 )
		processing_objects.Add( src )

/obj/item/device/spacepod_equipment/engine/Del()
	processing_objects.Remove( src )

	..()

/obj/item/device/spacepod_equipment/engine/process()
	if( my_atom )
		var/temp_fire = fire
		if( my_atom.fire_hazard() )
			if( prob( 10 )) // if the pod is damage enough, there is a chance of fire
				fire = 1
		if( fire )
			if( prob( 2 )) // Fires have a small chance of putting themselves out
				fire = 0
			else
				fire = 1
		if( fuel_tank.temperature >= max_temp )
			fire = 1

		if( fire != temp_fire )
			my_atom.update_icons()

		if( fire ) // If we agree that we're on fire, light em up
			fuel_tank.add_thermal_energy( fire_heat )

	fuel_tank.add_thermal_energy( -heat_rad_rate )

	if( fuel_tank.temperature >= max_temp ) // hurt em a bit for running it too hot
		my_atom.deal_damage( (fuel_tank.temperature/(4*max_temp))*heat_rate )

/obj/item/device/spacepod_equipment/engine/check()
	if( fuel_tank.total_moles > 0 )
		return 1
	else
		return 0

// Runs a single cycle of the engine
/obj/item/device/spacepod_equipment/engine/proc/cycle()
	if( use_fuel )
		if( fuel_tank.gas["phoron"] > 0 )
			fuel_tank.adjust_gas( "phoron", -burn_rate) // use up dat phoron
			fuel_tank.add_thermal_energy(heat_rate) // heat from the engine using phoron

			if( my_atom.equipment_system.battery ) // charge the battery if we have one
				my_atom.equipment_system.battery.give( charge_rate )

			/*
			if( fuel_tank.gas["oxygen"] > 0 )
				fuel_tank.adjust_gas( "oxygen", -burn_rate/2) // burn up oxygen at half rate 4noraisin
				fuel_tank.add_thermal_energy(heat_rate*10) // putting oxygen in this baby is bad news

				if( my_atom.equipment_system.battery ) // but hey, we'll charge the battery even faster
					my_atom.equipment_system.battery.give( charge_rate*2 )
			*/
		else
			my_atom.occupants_announce( "ERROR: No phoron left in the fuel tank!", 2 )
			return 0

	return 1

/obj/item/device/spacepod_equipment/engine/proc/fill( var/obj/item/weapon/tank/tank )
	if( !tank )
		usr << "That's not a valid tank!"
		return 0

	fuel_tank.merge( tank.air_contents )
	tank.air_contents.remove( tank.air_contents.volume )
	return 1

/obj/item/device/spacepod_equipment/engine/proc/get_temp()
	return fuel_tank.temperature

/obj/item/device/spacepod_equipment/engine/magic
	use_fuel = 0

/obj/item/device/spacepod_equipment/shield
	name = "\improper spacepod shield system"
	desc = "For particularily rainy days."
	icon_state = "shield"

/obj/item/device/spacepod_equipment/misc/autopilot
	name = "\improper spacepod autopilot system"
	desc = "Used to automatically pilot the shuttle to known locations."
	icon_state = "pod_locator"
	var/piloting = 0 // Are we currently on autopilot?
	var/obj/machinery/gate_beacon/destination = null
	var/list/path = null
	var/list/local_path = null
	var/obj/effect/map/sector = null // The current sector

/obj/item/device/spacepod_equipment/misc/autopilot/Del()
	if( processing_objects[src] )
		processing_objects.Remove( src )

	..()

/obj/item/device/spacepod_equipment/misc/autopilot/process()
	if( piloting )
		if( path ) // If we have our map acrossed the sectors, do our stuff
			if( sector != map_sectors["[my_atom.z]"] ) // If we're in a new sector
				testing( "[my_atom] entered a new sector" )
				sector = map_sectors["[my_atom.z]"]
				path.Remove( sector ) // Removing the current sector from the list of destinations
				get_local_path( get_end() )

			if( local_path ) // If we have a local path across the sector, do your magic
				if( local_path.len > 1 ) // Local path len will only fall to this low if we actually reach the end
					local_path.Remove( my_atom.loc )
					my_atom.Move( local_path[1] )
				else // If we arrived
					testing( "[my_atom] arrived at destination [destination]" )
					quit_pilot()
			else // If not, we need to make one
				testing( "Making new local path" )
				get_local_path( get_end() )

		else // Otherwise, we need one asap
			get_path()
	else
		testing( "process() quit piloting" )
		quit_pilot()
		processing_objects.Remove( src )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/prompt( var/mob/user = usr )
	testing( "Starting autopilot sequence" )
	var/target = input( user, "Where would you like to fly to?", "Destination", null ) in bluespace_beacons
	destination = bluespace_beacons[target]

	if( destination )
		get_path()

		if( path )
			testing( "Successfully found a path" )
			spawn( 30 )
				processing_objects.Add( src )
		else
			testing( "Could not find a path" )
			my_atom.occupants_announce( "Could not plot a course to [target]!" )
	else
		my_atom.occupants_announce( "Autopilot aborted." )
		testing( "Autopilot sequence aborted" )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_path()
	testing( "Getting autopilot path" )
	path = null
	if( !destination )
		testing( "No valid destination" )
		quit_pilot()
		return

	sector = map_sectors["[my_atom.z]"] // getting our current sector
	var/obj/effect/map/target = map_sectors["[destination.z]"] // getting our destination sector

	if( !sector )
		my_atom.occupants_announce( "Spacepod is not in a valid sector!" )
		testing( "Could not find pod sector" )
		quit_pilot()
		return
	if( !target )
		my_atom.occupants_announce( "Destination is not a valid target!" )
		testing( "Could not find destination sector" )
		quit_pilot()
		return

	path = AStar(sector.loc, target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 15)

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_end()
	var/turf/start = get_turf(my_atom)
	var/turf/end = null

	if( path )
		if( path.len > 0 )
			testing( "Finding edge of next sector" )
			var/obj/effect/map/next_sector = path[1]

			switch( get_dir( sector, next_sector ))
				if(NORTH)
					end = locate( start.x, world.maxy, start.z )
				if(SOUTH)
					end = locate( start.x, 1, start.z )
				if(EAST)
					end = locate( world.maxx, start.y, start.z )
				if(WEST)
					end = locate( 1, start.y, start.z )
		else
			testing( "Finding destination" )
			end = destination.loc
	else
		testing( "end_turf() called with no path" )

	return end

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_local_path( var/turf/end )
	testing( "Finding local path" )
	local_path = null
	local_path = AStar(my_atom.loc, end, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 15)

/obj/item/device/spacepod_equipment/misc/autopilot/proc/quit_pilot()
	testing( "Quitting autopilot sequence" )
	piloting = 0
	path = null
	local_path = null
	destination = null