/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_bar)

	rank_succesion_level = 3

/datum/job/bartender/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/bar(H), slot_belt)
	if(prob(20))
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/tophat(H), slot_head)

	if(H.character.backpack == 1)
		var/obj/item/weapon/storage/box/survival/Barpack = new /obj/item/weapon/storage/box/survival(H)
		H.equip_to_slot_or_qdel(Barpack, slot_r_hand)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

	return 1

/datum/job/bartender/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "ba_suit_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "tophat"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s