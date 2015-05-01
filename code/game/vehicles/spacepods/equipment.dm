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
	my_atom.equipment_system.battery.use(shot_cost)
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
			return 1
		else
			if( user )
				user << "\red That's not valid equipment!"
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
		return 1
	else
		user << "<span class='notice'>You can't remove the [equipment]!</span>"

	return 0

// Assigns proper systems
/datum/spacepod/equipment/proc/assign_system(var/obj/item/equipment)
	if(istype( equipment, /obj/item/device/spacepod_equipment/weaponry )) // Assigning the weapon system
		weapon_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/misc )) // Assigning misc systems
		misc_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/engine )) // Assigning the engine system
		engine_system = equipment
	else if(istype( equipment, /obj/item/device/spacepod_equipment/shield )) // Assigning the shield system
		shield_system = equipment
	else if(istype( equipment, /obj/item/weapon/cell )) // Assigning the battery
		battery = equipment
	else if(!istype( equipment, /obj/item/device/spacepod_equipment ))  // If it wasn't any of those systems, and isn't spacepod_equipment, we don't want what you're selling
		return 0

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.my_atom = my_atom

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
	else if( equipment == battery ) // Assigning the battery
		battery = null
	else if(!istype( equipment, /obj/item/device/spacepod_equipment ))  // If it wasn't any of those systems, and isn't spacepod_equipment, we don't want what you're selling
		world << "MAH EMULSION: Tried to remove an impossible object from the spacepod, yell at Kwask."
		return 0

	if( istype( equipment, /obj/item/device/spacepod_equipment ))
		var/obj/item/device/spacepod_equipment/equipped = equipment
		equipped.my_atom = null

	return 1

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
// base item for spacepod weapons

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
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
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(enabled)
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
	icon_state = "pod_locator"

/obj/item/device/spacepod_equipment/shield
	name = "\improper spacepod shield system"
	desc = "For particularily rainy days."
	icon_state = "pod_locator"