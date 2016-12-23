/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF_ENGINEER
	department_id = ENGINEERING
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	
	alt_titles = list("Engineering Director")
	
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_engine_core,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_change_ids, access_desublimation)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_engine_core,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_change_ids, access_desublimation)

	rank_succesion_level = COMMAND_SUCCESSION_LEVEL

	dep_authority = list( ENGINEERING )

/datum/job/chief_engineer/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/ce(H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chief_engineer(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/heads/ce(H), slot_l_store)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/head/hardhat/white(H), slot_head)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
	return 1

/datum/job/chief_engineer/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "blueprints"), ICON_OVERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
