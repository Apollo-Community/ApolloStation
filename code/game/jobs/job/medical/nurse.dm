/datum/job/nurse
	title = "Nurse"
	flag = NURSE
	department_id = MEDICAL
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue)
	minimal_access = list(access_medical, access_morgue)

	rank_succesion_level = INDUCTEE_SUCCESSION_LEVEL

/datum/job/nurse/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)


	if(H.gender == FEMALE)
		if(prob(50))			H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/nurse_dress(H), slot_w_uniform)
		else					H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/nurse(H), slot_w_uniform)
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

/datum/job/nurse/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	if(gender == "f")
		if(prob(50))			clothes_s = new /icon('icons/mob/uniform.dmi', "nurse_s")
		else					clothes_s = new /icon('icons/mob/uniform.dmi', "nursesuit_s")
		clothes_s.Blend(icon('icons/mob/head.dmi', "nursehat"), ICON_OVERLAY)
	else
		clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")

	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)

	switch(backpack)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
		else			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)

	return clothes_s
