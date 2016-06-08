/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_id = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list( "Off-Duty Personnel", "Waiter", "Steward", "Attendant", "Tourist" )

	rank_succesion_level = ASSISTANT_SUCCESSION_LEVEL

/datum/job/assistant/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0

	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)

	if(H.job == "Waiter" || H.job == "Attendant" || H.job == "Steward")
		if(H.gender == FEMALE)	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/black_tango/short(H), slot_w_uniform)
		else					H.equip_to_slot_or_qdel(new /obj/item/clothing/under/waiter(H), slot_w_uniform)
	else if(H.job == "Tourist")
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/tourist(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_to_slot_or_qdel(new /obj/item/device/camera(H), slot_l_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/folder/tourist(H), slot_l_store)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/pen/random(H), slot_r_store)
		H.equip_to_slot_or_qdel(new /obj/item/device/camera_film(H.back), slot_in_backpack)
	else						H.equip_to_slot_or_qdel(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)

	if(H.job == "Tourist")	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
	else					H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

/datum/job/assistant/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null
	if(job == "Tourist")
		clothes_s = new /icon('icons/mob/uniform.dmi', "tourist_s")
	//	clothes_s.Blend('icons/mob/eyes.dmi', "sun", ICON_OVERLAY)		This breaks stuff? No idea why
	else if(job == "Garcon")
		if(gender == "f")	clothes_s = new /icon('icons/mob/uniform.dmi', "black_tango_short_s")
		else				clothes_s = new /icon('icons/mob/uniform.dmi', "waiter_s")
	else					clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")

	if(job == "Tourist")	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "wizard"), ICON_UNDERLAY)
	else					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)

	if(backpack == 2)						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
	else if(backpack == 3 || backpack == 4)	clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
