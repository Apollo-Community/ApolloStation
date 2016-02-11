/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_id = SECURITY
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels)
	minimal_player_age = 3

	rank_succesion_level = 4

/datum/job/officer/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/security(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/security(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/security(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/handcuffs(H), slot_s_store)
	H.equip_to_slot_or_qdel(new /obj/item/device/flash(H), slot_l_store)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/handcuffs(H), slot_l_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/tie/holster(H), slot_in_backpack)
	return 1

/datum/job/officer/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "officerberet"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s