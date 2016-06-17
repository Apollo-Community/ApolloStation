//More or less assistants
/datum/job/lawyer
	title = "Attorney"
	flag = LAWYER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list( access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_lawyer, access_court)
	alt_titles = list("Lawyer")

	minimal_playtime = 2

	rank_succesion_level = 3

/datum/job/lawyer/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	var/suit = pick( /obj/item/clothing/under/suit_jacket/burgundy,
		 			 /obj/item/clothing/under/suit_jacket/navy,
		 			 /obj/item/clothing/under/suit_jacket/charcoal,
		 			 /obj/item/clothing/under/suit_jacket/really_black )

	H.equip_to_slot_or_qdel(new suit(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/lawyer/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "charcoal_suit_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "hairflower"), ICON_OVERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
