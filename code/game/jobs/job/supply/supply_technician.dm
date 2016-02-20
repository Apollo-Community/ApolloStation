/datum/job/supply_tech
	title = "Supply Technician"
	flag = SUPPLYTECH
	department_id = SUPPLY
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)

	rank_succesion_level = INDUCTEE_SUCCESSION_LEVEL

/datum/job/supply_tech/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/cargo(H), slot_belt)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/supply_tech/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "cargo_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "flat_cap"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s