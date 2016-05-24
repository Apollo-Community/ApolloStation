/datum/job/foreman
	title = "Mining Foreman"
	flag = FOREMAN
	department_id = SUPPLY
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_slater)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting, access_slater)

	rank_succesion_level = 5

/datum/job/mining/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_cargo (H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/shaftminer(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/crowbar(H), slot_l_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/crowbar(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
	return 1

/datum/job/mining/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "bearpelt"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s