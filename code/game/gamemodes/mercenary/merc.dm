/datum/antagonist/mercenary
	name = "Mercenary"
	faction = /datum/faction/syndicate/marauders/mercenaries
	can_buy = 0

/datum/antagonist/mercenary/greet()
	antag.current << "<B><font size=3 color=red>You are a Mercenary.</font></B>"
	antag.current << "<B><font size=2 color=red>You are an operative of the Gorlex Marauders Task Force.</font></B>"
	antag.current << "Your squad has been assigned a contract by the Syndicate Workforce Delegation. It is your squad's job to carry it out."
	antag.current << "Your code name for this mission will be <B>[antag.current.real_name]</B>."
	antag.current << ""

	var/datum/game_mode/mercenary/cur_mode = ticker.mode
	if(!cur_mode)
		return

	antag.current << "<B><font size=3 color=red>The contract is as follows:</font></B>"
	antag.current << "<B>[cur_mode.merc_contract.title]</B>\n<I>[cur_mode.merc_contract.desc]</I>"
	if( cur_mode.merc_contract.time_limit )
		antag.current << "You and your squad have until [worldtime2text(cur_mode.merc_contract.contract_start + cur_mode.merc_contract.time_limit)], station time, to complete the contract. <B><font color=red>Failure is not an option.</font></B>"
	else
		antag.current << "You have all the time could you need at your disposal. Your only requirement is to finish the contract. <B><font color=red>Failure is not an option.</font></B>"
	antag.current << ""

/datum/antagonist/mercenary/equip()
	var/mob/living/mob = antag.current

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(mob)
	R.set_frequency(SYND_FREQ)
	R.freerange = 1
	mob.equip_to_slot_or_qdel(R, slot_l_ear)

	mob.equip_to_slot_or_qdel(new /obj/item/clothing/under/syndicate(mob), slot_w_uniform)
	mob.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(mob), slot_shoes)
	mob.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/swat(mob), slot_gloves)
	mob.equip_to_slot_or_qdel(new /obj/item/weapon/card/id/syndicate(mob), slot_wear_id)

	//if(mob.character.backpack == 2) mob.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(mob), slot_back)
	mob.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(mob), slot_back)
	//if(mob.character.backpack == 4) mob.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(mob), slot_back)

	mob.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(mob.back), slot_in_backpack)
	mob.equip_to_slot_or_qdel(new /obj/item/weapon/reagent_containers/pill/cyanide(mob), slot_in_backpack)

	mob.update_icons()

	return 1
