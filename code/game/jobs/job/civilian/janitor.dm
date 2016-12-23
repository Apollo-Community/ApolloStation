/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)

	rank_succesion_level = 3
	
	alt_titles = list("Sanitary Engineer")

/datum/job/janitor/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/janitor(H), slot_belt)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/janitor/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bio_janitor"), ICON_OVERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
