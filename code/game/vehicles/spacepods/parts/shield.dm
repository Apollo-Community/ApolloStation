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
