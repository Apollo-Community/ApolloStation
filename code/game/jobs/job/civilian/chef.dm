/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_kitchen)
	alt_titles = list("Cook","Cafeteria Attendant","Gardener")

	rank_succesion_level = 3

/datum/job/chef/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0

	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)

	if(H.job == "Gardener")
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
		H.equip_to_slot_or_qdel(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/botanist(H), slot_belt)
		switch(H.character.backpack)
			if(1) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/hydroponics(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_hyd(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	else
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/chefhat(H), slot_head)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/chef(H), slot_belt)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/chef/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null
	if(job == "Gardener")
		clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
	else
		clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "chefhat"), ICON_OVERLAY)
		if(prob(1))			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apronchef"), ICON_OVERLAY)
		else				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "chef"), ICON_OVERLAY)

	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)

	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
