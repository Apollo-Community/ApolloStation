/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_id = SCIENCE
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeef0"
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_xenoarch, access_chemistry )
	minimal_access = list(access_chemistry, access_research, access_xenoarch)
	alt_titles = list("Pharmacist")

	rank_succesion_level = 4

/datum/job/chemist/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/chemist(H), slot_belt)
	switch(H.character.backpack)
		if(1) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/chemistry(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_chem(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/chemist(H), slot_wear_suit)
	return 1

/datum/job/chemist/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labgreen"), ICON_OVERLAY)
	else
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-chem"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s