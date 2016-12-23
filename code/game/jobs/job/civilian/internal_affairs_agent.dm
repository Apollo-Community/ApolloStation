//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/iaa
	title = "Internal Affairs Agent"
	flag = IAA
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_iaa, access_court, access_sec_doors, access_maint_tunnels, access_medical, access_morgue, access_research, access_tox, access_security, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_eva, access_engine, access_engine_equip, access_external_airlocks, access_construction, access_bar, access_janitor,
access_crematorium, access_kitchen, access_hydroponics, access_theatre, access_chapel_office, access_library, access_clown, access_mime)
	minimal_access = list(access_iaa, access_court, access_sec_doors, access_maint_tunnels, access_medical, access_morgue, access_research, access_tox, access_security, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_eva, access_engine, access_engine_equip, access_external_airlocks, access_construction, access_bar, access_janitor,
access_crematorium, access_kitchen, access_hydroponics, access_theatre, access_chapel_office, access_library, access_clown, access_mime)

	minimal_playtime = 30

	rank_succesion_level = COMMAND_SUCCESSION_LEVEL

/datum/job/iaa/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/hop/iaa(H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/internalaffairs(H), slot_wear_suit)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses/big(H), slot_glasses)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/lawyer(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1

/datum/job/iaa/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "internalaffairs_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
