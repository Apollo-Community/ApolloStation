/datum/job/senior_scientist
	title = "Senior Scientist"
	flag = SENIOR_SCIENTIST
	department_id = SCIENCE
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the research director"
	selection_color = "#ffeeff"
	access = list(access_tcomsat, access_robotics, access_tox, access_research, access_moon, access_xenobiology, access_xenoarch)
	minimal_access = list(access_tcomsat, access_robotics, access_tox, access_research, access_moon)
	alt_titles = list("Communications Specialist", "Xenobiologist", "Xenobotanist", "Xenoarcheologist", "Toxins Specialist", "Research Specialist", "Mechatronic specialist", "Chemical Specialist")

	rank_succesion_level = 5

/datum/job/scientist/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	if(H.job == "Chemical Specialist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
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
	else if(H.job == "Mechatronic Specialist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
		if(H.character.backpack == 2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.character.backpack == 3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/roboticist(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)
		return 1
	else if(H.job == "Xenobiologist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/science(H), slot_belt)
		switch(H.character.backpack)
			if(1) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/toxins(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/science(H), slot_wear_suit)
		return 1
	else
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/science(H), slot_belt)
		switch(H.character.backpack)
			if(1) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/toxins(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/science(H), slot_wear_suit)
	return 1

/datum/job/scientist/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "sciencewhite_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "metroid"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-tox"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s