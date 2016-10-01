/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_id = MEDICAL
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_genetics, access_chemistry, access_surgery)
	minimal_access = list(access_medical, access_morgue, access_chemistry, access_surgery)
	alt_titles = list("First Responder", "Psychiatrist", "Diagnostician", "Mortician", "Pharmacist", "Surgeon")

	rank_succesion_level = 4

/datum/job/doctor/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	if(H.job != "Pharmacist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)

	if(H.job == "Surgeon")
		if(prob(33))
			H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/medical/green(H), slot_w_uniform)
			H.equip_to_slot_or_qdel(new /obj/item/clothing/head/surgery/green(H), slot_head)
		else if(prob(33))
			H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/medical/blue(H), slot_w_uniform)
			H.equip_to_slot_or_qdel(new /obj/item/clothing/head/surgery/blue(H), slot_head)
		else
			H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/medical/purple(H), slot_w_uniform)
			H.equip_to_slot_or_qdel(new /obj/item/clothing/head/surgery/purple(H), slot_head)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)
	else if("First Responder")
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/fr_jacket(H), slot_wear_suit)
	else if("Psychiatrist")
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/psych(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)
	else if("Pharmacist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/chemist(H), slot_belt)
	else	//Catch all for medical titles.
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	H.equip_to_slot_or_qdel(new /obj/item/device/pda/medical(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/device/flashlight/pen(H), slot_s_store)
	return 1

/datum/job/doctor/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")

	if(job == "First Responder")	clothes_s.Blend(new /icon('icons/mob/suit.dmi', "fr_jacket"), ICON_OVERLAY)
	else							clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)

	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
