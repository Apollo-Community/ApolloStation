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
