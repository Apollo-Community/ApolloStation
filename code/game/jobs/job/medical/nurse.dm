/datum/job/nurse
	title = "Nurse"
	flag = NURSE
	department_id = MEDICAL
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_chemistry)
	minimal_access = list(access_medical, access_morgue)

	rank_succesion_level = INDUCTEE_SUCCESSION_LEVEL

/datum/job/nurse/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)

	if("Nurse")
		if(H.gender == FEMALE)
			if(prob(50))
				H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/nurse_dress(H), slot_w_uniform)
			else
				H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/nurse(H), slot_w_uniform)
			H.equip_to_slot_or_qdel(new /obj/item/clothing/head/nursehat(H), slot_head)
		else
			H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/nurse_suit(H), slot_w_uniform)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/medical(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/device/flashlight/pen(H), slot_s_store)
	return 1

/datum/job/nurse/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)

	switch(backpack)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
		else
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)

	return clothes_s
