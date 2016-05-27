/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_id = SECURITY
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_change_ids)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_change_ids)

	rank_succesion_level = COMMAND_SUCCESSION_LEVEL

/datum/job/hos/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/security(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/hos(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/head_of_security(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/heads/hos(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses/sechud(H), slot_glasses)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/gun/energy/gun(H), slot_s_store)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/handcuffs(H), slot_l_store)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
	H.implant_loyalty(H)
	return 1

/datum/job/hos/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "hosred_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "hosberet"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
