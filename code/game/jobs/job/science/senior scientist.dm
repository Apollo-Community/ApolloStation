/datum/job/senior_scientist
	title = "Senior Scientist"
	flag = SENIOR_SCIENTIST
	department_id = SCIENCE
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the research director"
	selection_color = "#ffeeff"
	access = list(access_tcomsat, access_robotics, access_tox, access_research, access_moon, access_xenobiology, access_xenoarch, access_chemistry)
	minimal_access = list(access_robotics, access_tox, access_research, access_moon, access_xenobiology, access_xenoarch, access_chemistry, access_eva)
	alt_titles = list("Xenobiologist", "Xenobotanist", "Xenoarcheologist", "Phoron Specialist", "Research Specialist", "Mechatronic Specialist", "Chemical Researcher")

	rank_succesion_level = 5

/datum/job/senior_scientist/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	if(H.job == "Chemical Researcher")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/chemist(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/chemist(H), slot_wear_suit)
	else if(H.job == "Mechatronic Specialist")
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/roboticist(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat(H), slot_wear_suit)
	else
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/science(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/science(H), slot_wear_suit)

	if(H.job == "Chemical Researcher")
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/chemistry(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_chem(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	else
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/toxins(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1

/datum/job/senior_scientist/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null
	if(job == "Chemical Researcher")
		clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
		if(prob(1))			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labgreen"), ICON_OVERLAY)
		else				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
	else if(job == "Mechatronic Specialist")
		clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
		clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if(prob(1))			clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
	else
		clothes_s = new /icon('icons/mob/uniform.dmi', "sciencewhite_s")
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)

	if(prob(1))		clothes_s.Blend(new /icon('icons/mob/head.dmi', "metroid"), ICON_OVERLAY)

	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "[job == "Mechatronic Specialist" ? "black" : "white"]"), ICON_UNDERLAY)

	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "[job == "Chemical Researcher" ? "satchel-chem" : "satchel-tox"]"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
