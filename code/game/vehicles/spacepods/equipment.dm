/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/list/spacepod_equipment = list()
	var/max_size = 5

	// Various systems for fast retrieval
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system  // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system
	var/obj/item/device/spacepod_equipment/misc/cargo/cargohold // shielding system
	var/obj/item/weapon/cell/battery // the battery, durh
	var/obj/item/pod_parts/armor/armor // what kind of armor it has
//	var/obj/item/device/spacepod_equipment/misc/autopilot/autopilot // the autopilot
	var/list/seats = list()

/datum/spacepod/equipment/New(var/obj/spacepod/SP, max_size)
	..()

	if(istype(SP))
		my_atom = SP

/datum/spacepod/equipment/proc/equip(var/obj/item/equipment, var/mob/user = null)
	if( spacepod_equipment.len < max_size )
		if( assign_system( equipment )) // Adding the special systems
			spacepod_equipment.Add( equipment )
			if( user )
				user << "<span class='notice'>You insert \the [equipment] into \the [my_atom].</span>"
				user.drop_item(equipment)
			playsound( get_turf( my_atom ), 'sound/effects/equip.ogg', 50, 1 )
			equipment.loc = src
			my_atom.update_icons()
			return 1
		else
			if( user )
				user << "\red Could not add [equipment] to \the [my_atom]."
			return 0
	else
		if( user )
			user << "\red There's no space left for \the [equipment]!"
		return 0

/datum/spacepod/equipment/proc/dequip(var/obj/item/equipment, var/mob/user = null)
	deassign_system( equipment )
	spacepod_equipment.Remove( equipment )
	my_atom.update_icons()

	if( user )
		if( user.put_in_any_hand_if_possible(equipment))
			user << "<span class='notice'>You remove \the [equipment] from the [my_atom]</span>"
			return 1

	equipment.loc = get_step( my_atom.loc, turn( my_atom.dir, 180 )) // putting the items behind the spacepod
	return 1

// Assigns proper systems
/datum/spacepod/equipment/proc/assign_system(var/obj/item/equipment)
	if( istype( equipment, /obj/item/device/spacepod_equipment/weaponry )) // Assigning the weapon system
		weapon_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/engine )) // Assigning the engine system
		if( engine_system )
			return 0
		engine_system = equipment
	else if( istype( equipment, /obj/item/device/spacepod_equipment/shield )) // Assigning the shield system
		if( shield_system )
			return 0
		shield_system = equipment
	else if( istype( equipment, /obj/item/device/spacepod_equipment/seat )) // Assigning seats
		seats.Add( equipment )
/*	else if( istype( equipment, /obj/item/device/spacepod_equipment/misc/autopilot )) // Assigning the shield system
		if( autopilot )
			return 0
		autopilot = equipment*/
	else if( istype( equipment, /obj/item/device/spacepod_equipment/misc/cargo )) // Assigning seats
		if( cargohold )
			return 0
		cargohold = equipment
	else if( istype( equipment, /obj/item/device/spacepod_equipment/misc )) // Assigning misc systems
		misc_system = equipment
	else if( istype( equipment, /obj/item/weapon/cell )) // Assigning the battery
		if( battery )
			return 0
		battery = equipment
	else if( istype( equipment, /obj/item/pod_parts/armor )) // And finally, armor
		if( armor )
			return 0
		armor = equipment

		my_atom.health = 100+armor.health_bonus
		max_size = armor.equipment_size

	else if(!istype( equipment, /obj/item/device/spacepod_equipment ))  // If it wasn't any of those systems, and isn't spacepod_equipment, we don't want what you're selling
		return 0

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.assign(src.my_atom)

	return 1

// Deassigns proper system
/datum/spacepod/equipment/proc/deassign_system(var/obj/item/equipment)
	if( equipment == weapon_system ) // Deassigning the weapon system
		weapon_system = null
	else if( equipment == misc_system ) // Deassigning misc systems
		misc_system = null
	else if( equipment == engine_system ) // Deassigning the engine system
		engine_system = null
	else if( equipment == shield_system ) // Deassigning the shield system
		shield_system = null
	else if( locate( equipment ) in seats ) // Removing the seat
		seats.Remove( equipment )
/*	else if( equipment == autopilot ) // Deassigning the battery
		autopilot = null*/
	else if( equipment == cargohold ) // Deassigning the cargohold
		cargohold = null
	else if( equipment == battery ) // Deassigning the battery
		battery = null
	else if( equipment == armor )
		reset_default()
		my_atom.update_icon()
		return 1

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.deassign()

	my_atom.update_icon()
	return 1

/datum/spacepod/equipment/proc/reset_default()
	armor = null
	my_atom.health = 100
	max_size = 5

	spawn( 1 )
		dump_equipment()

/datum/spacepod/equipment/proc/dump_equipment()
	my_atom.loc.visible_message( "The entire equipment system of the [my_atom] is dumped out of the back" )

	for( var/obj/equipment in spacepod_equipment )
		dequip( equipment )

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
	var/manufacturer = "NanoTrasen" // purely a fluffy detail

/obj/item/device/spacepod_equipment/examine(mob/user)
	..(user)
	user << "This part has printed on the back, \"Manufactured by [manufacturer]\"."

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
	manufacturer = "Hesphaistos Industries"

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
	name = "\improper tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/check()
	return enabled

/obj/item/device/spacepod_equipment/seat
	name = "\improper seat"
	desc = "An extra seat for your spacepods, to squeeze in extra spacemen for those space rides."
	icon_state = "seat"

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
			my_atom.update_icons()

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

/obj/item/device/spacepod_equipment/shield
	name = "Lancelot P3R (shield)"
	desc = "A shield system designed to negate energy from attacks."
	icon_state = "shield"
	var/max_negate = 20 // The maximum amount of damage that the shield can totally block
	var/charge_multiplier = 20 // How much charge it takes per unit of damage

/obj/item/device/spacepod_equipment/shield/proc/hit( var/damage )
	var/obj/item/weapon/cell/battery = my_atom.equipment_system.battery

	if( battery )
		if( battery.charge > 0 )
			var/negated = max_negate-damage
			var/charge_cost = 0

			if( negated >= 0 )
				charge_cost = charge_multiplier*negated
				damage = 0
				battery.charge = max( 0, battery.charge-charge_cost )

				my_atom.occupants_announce( "ALERT: Shield absorbed all damage. Battery at [10*(battery.charge/battery.maxcharge)]%!" )
			else
				charge_cost = charge_multiplier*max_negate
				damage -= max_negate
				battery.charge = max( 0, battery.charge-charge_cost )
				my_atom.occupants_announce( "ALERT: Shield absorbed some damage. Battery at [10*(battery.charge/battery.maxcharge)]%!" )
			my_atom.play_interior_sound( 'sound/effects/eshield_hit.ogg' )

	my_atom.deal_damage( damage )

/obj/item/device/spacepod_equipment/misc/cargo
	name = "cargohold"
	icon_state = "cargohold"
	desc = "Used to securely store crates and other such items inside of a spacepod."
	var/max_size = 5

/obj/item/device/spacepod_equipment/misc/cargo/proc/put_inside(var/obj/O, var/mob/user = usr)
	if( !O ) return 0
	if( src.contents.len >= max_size )
		user << "\red The [my_atom]\'s cargohold is full!"
		return 0
	if( O.anchored && !istype( O, /obj/mecha ))
		user << "\red You can't move that!"
		return 0
	if ( istype( O, /obj/item/weapon/grab ))
		return 0

	user.drop_item()
	if( O.loc != src )
		if( istype( O, /obj/mecha ))
			var/obj/mecha/M = O
			M.go_out()
		O.loc = src
		my_atom.visible_message( "[user] loads the [O] into [my_atom]\'s cargohold." )

	return 1

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_prompt( var/mob/user = usr )
	if( !src.contents.len )
		user << "\red There's nothing to dump!"
		return 0

	var/list/answers = list( "All" )
	for( var/obj/O in src )
		answers.Add( O )

	var/response = input( user, "What cargo do you want to dump?", "Dump Cargo", null ) in answers

	if( response == "All" )
		dump_all()
	else
		if( istype( response, /obj ))
			dump_item( response )
		else
			user << "\red Not a valid object for dumping!"
			return 0

	return 1

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_all()
	for( var/obj/O in src )
		dump_item( O )

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_item( var/obj/O )
	O.loc = get_step( my_atom.loc, turn( my_atom.dir, 180 )) // putting the items behind the spacepod

/obj/item/device/spacepod_equipment/misc/cargo/deassign()
	..()

	dump_all()

/*
/obj/item/device/spacepod_equipment/misc/autopilot
	name = "\improper autopilot system"
	desc = "Used to automatically pilot the shuttle to known locations."
	icon_state = "autopilot"
	var/piloting = 0 // Are we currently on autopilot?
	var/obj/machinery/gate_beacon/destination = null
	var/list/path = null
	var/turf/local_end = null
	var/obj/effect/map/sector = null // The current sector
	manufacturer = "Ward-Takahashi GMB"

/obj/item/device/spacepod_equipment/misc/autopilot/Destroy()
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
				local_end = get_end()

			if( local_end ) // If we have a local path across the sector, do your magic
				if( my_atom.loc != local_end ) // Local path len will only fall to this low if we actually reach the end
					my_atom.set_dir( get_dir( my_atom,local_end ))
					var/turf/T = get_step( my_atom.loc, my_atom.dir )
					my_atom.Move( T )
				else // If we arrived
					testing( "[my_atom] arrived at destination [destination]" )
					quit_pilot()
			else // If not, we need to make one
				testing( "Finding new local_end" )
				local_end = get_end()

		else // Otherwise, we need one asap
			get_path()
	else
		testing( "process() quit piloting" )
		quit_pilot()
		processing_objects.Remove( src )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/prompt( var/mob/user = usr )
	testing( "Starting autopilot sequence" )
	testing( "prompt() called" )

	var/target = input( user, "Where would you like to fly to?", "Destination", null ) in bluespace_beacons
	destination = bluespace_beacons[target]

	if( destination )
		get_path()

		if( path )
			testing( "Successfully found a path" )
			piloting = 1
			spawn( 30 )
				processing_objects.Add( src )
		else
			testing( "Could not find a path" )
			my_atom.occupants_announce( "Could not plot a course to [target]!" )
	else
		my_atom.occupants_announce( "Autopilot aborted." )
		testing( "Autopilot sequence aborted" )

	if( piloting )
		testing( "prompt() completed successfully" )
	else
		testing( "prompt() completed unsuccessfully" )

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_path()
	testing( "get_path() called" )
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

	path = AStar(sector.loc, target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 0 )

	if( path )
		testing( "get_path() returned with a path" )
	else
		testing( "get_path() returned without a path" )

	return path

/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_end()
	testing( "get_end() called" )
	var/turf/start = my_atom.loc
	var/turf/end = null

	if( start )
		testing( "start found at [start]" )
	else
		testing( "start found nothing" )

	if( path )
		if( path.len > 1 )
			testing( "Finding edge of next sector" )
			var/obj/effect/map/next_sector = path[1]

			switch( get_dir( sector, next_sector ))
				if(NORTH)
					end = locate( start.x, world.maxy-1, start.z )
				if(SOUTH)
					end = locate( start.x, 1, start.z )
				if(EAST)
					end = locate( world.maxx-1, start.y, start.z )
				if(WEST)
					end = locate( 1, start.y, start.z )

			if( end )
				testing( "end found end at [end]" )
			else
				testing( "end found at nothing" )
		else
			testing( "Finding destination" )
			end = destination.loc
	else
		testing( "no sector path" )

	if( end )
		testing( "end_turf() returned with [end]" )
	else
		testing( "end_turf() returned with null" )

	return end

/*
/proc/greater_or_less( var/a, var/b )
	if( a > b )
		return -1
	else if( a == b )
		return 0
	else if( a < b )
		return 1


/obj/item/device/spacepod_equipment/misc/autopilot/proc/get_local_path( var/turf/end )
	testing( "get_local_path() called" )
	testing( "Finding local path from [my_atom.loc] to [end]" )
	local_path = list()
	var/pathx_it = greater_or_less( my_atom.x, end.x  )
	var/pathy_it = greater_or_less( my_atom.y, end.y )

	if( pathx_it != 0 && pathy_it != 0 )
		for( var/pathx = my_atom.x; pathx != end.x; pathx += pathx_it )
			for( var/pathy = my_atom.y; pathy != end.y; pathy += greater_or_less( pathy, my_atom.y ))
				var/turf/T = locate( pathx, pathy, my_atom.z )

				local_path.Add(T)
			if( local_path.len >= world.maxx )
				break
	else if( pathx_it != 0 )
		for( var/pathx = my_atom.x; pathx != end.x; pathx += pathx_it )
			var/turf/T = locate( pathx, my_atom.y, my_atom.z )

			local_path.Add(T)

			if( local_path.len >= world.maxx )
				break
	else if( pathy_it != 0 )
		for( var/pathy = my_atom.y; pathy != end.y; pathy += pathy_it )
			var/turf/T = locate( my_atom.x, pathy, my_atom.z )

			local_path.Add(T)

			if( local_path.len >= world.maxx )
				break


	if( local_path )
		testing( "get_local_path() returned with a path" )
	else
		testing( "get_local_path() returned without a path" )

	return local_path
*/

/obj/item/device/spacepod_equipment/misc/autopilot/proc/quit_pilot()
	testing( "quit_pilot() called" )

	if( processing_objects[src] )
		processing_objects.Remove( src )

	piloting = 0
	path = null
	local_end = null
	destination = null

	testing( "quit_pilot() returned" )

*/
