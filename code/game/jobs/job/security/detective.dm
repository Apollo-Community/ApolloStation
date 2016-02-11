/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_id = SECURITY
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	alt_titles = list("Forensic Technician")

	rank_succesion_level = 4

	access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	minimal_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	alt_titles = list("Forensic Technician")
	minimal_player_age = 3

/datum/job/detective/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/det(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/detective(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/flame/lighter/zippo(H), slot_l_store)
	if(H.character.backpack == 1)//Why cant some of these things spawn in his office?
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/evidence(H), slot_l_hand)
		H.equip_to_slot_or_qdel(new /obj/item/device/detective_scanner(H), slot_r_store)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/evidence(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/device/detective_scanner(H), slot_in_backpack)
	if(H.mind.role_alt_title && H.mind.role_alt_title == "Forensic Technician")
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/forensics/blue(H), slot_wear_suit)
	else
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/det_suit(H), slot_wear_suit)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/det_hat(H), slot_head)
	return 1

/datum/job/detective/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s