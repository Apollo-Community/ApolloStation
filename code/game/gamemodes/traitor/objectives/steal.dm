datum/objective/steal/antiquelaser
	target_type = /obj/item/weapon/gun/energy/laser/captain
	explanation_text = "Steal the captain's antique laser gun"

datum/objective/steal/handtele
	target_type = /obj/item/weapon/hand_tele
	explanation_text = "Steal a hand teleporter."

datum/objective/steal/rcd
	target_type = /obj/item/weapon/rcd
	explanation_text = "Steal a rapid construction device."

datum/objective/steal/jumpsuit
	target_type = /obj/item/clothing/under/rank/captain
	explanation_text = "Steal the captain's jumpsuit."

datum/objective/steal/aicard
	target_type = /obj/item/device/aicard
	explanation_text = "Steal an intellicard and download a functional AI onto it."

	check_completion()
		if(!target_type || !owner.current)	return 0
		if( !isliving( owner.current ))	return 0

		var/list/all_items = owner.current.get_contents()
		for( var/obj/item/device/aicard/C in all_items ) //Check for ai card
			for( var/mob/living/silicon/ai/M in C )
				if( istype( M, /mob/living/silicon/ai) && M.stat != 2 ) //See if any AI's are alive inside that card.
					return 1
		return 0

datum/objective/steal/blueprints
	target_type = /obj/item/blueprints
	explanation_text = "Steal the blueprints of the station."

datum/objective/steal/tank
	target_type = /obj/item/weapon/tank
	explanation_text = "Steal a tank of phoron gas. Make sure it is fully filled."

	check_completion()
		if(!target_type || !owner.current)	return 0
		if( !isliving( owner.current ))	return 0

		var/list/all_items = owner.current.get_contents()

		var/target_amount = 28.0
		for(var/obj/item/I in all_items) //Check for phoron tanks
			if( istype( I, target_type ))
				return  I:air_contents:gas["phoron"] >= target_amount
		return 0

datum/objective/steal/slimeextract
	target_type = /obj/item/slime_extract
	explanation_text = "Steal any type of slime extract."

datum/objective/steal/pinpointer
	target_type = /obj/item/weapon/pinpointer
	explanation_text = "Steal the nuclear disk pinpointer."

datum/objective/steal/ablative
	target_type = /obj/item/clothing/suit/armor/laserproof
	explanation_text = "Steal an ablative armor vest."

datum/objective/steal/hypospray
	target_type = /obj/item/weapon/reagent_containers/hypospray
	explanation_text = "Steal the hypospray."

datum/objective/steal/nukedisk
	target_type = /obj/item/weapon/disk/nuclear
	explanation_text = "Steal the nuclear disk."