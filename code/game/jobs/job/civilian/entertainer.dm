/datum/job/mime
	title = "Mime"
	flag = ENTERTAINER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)

	rank_succesion_level = 2

/datum/job/mime/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	/*if(H.job == "Jester")
		if(H.character.backpack == 2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.character.backpack == 3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/jester(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/jester(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/clown(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/jesterhat(H), slot_head)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.mutations.Add(CLUMSY)
		return 1
	else if(H.job == "Mime")*/
	if(H.character.backpack == 2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
	if(H.character.backpack == 3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/mime(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/mime(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/white(H), slot_gloves)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		H.equip_to_slot_or_qdel(new /obj/item/toy/crayon/mime(H), slot_l_store)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
	H.verbs += /client/proc/mimespeak
	H.mind.special_verbs += /client/proc/mimespeak
	//H.verbs += /client/proc/mimewall
	//H.mind.special_verbs += /client/proc/mimewall
	H.miming = 1
	return 1
	/*else
		if(H.character.backpack == 2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.character.backpack == 3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/entertainer(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/mime(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/tophat/entertainer(H), slot_head)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1*/

/datum/job/mime/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "mime_s")
	if(prob(5))	clothes_s.Blend(new /icon('icons/mob/head.dmi', "butt"), ICON_OVERLAY)
	else		clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
