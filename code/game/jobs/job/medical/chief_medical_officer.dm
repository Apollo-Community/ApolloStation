/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_id = MEDICAL
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist, access_change_ids, access_chemistry, access_maint_tunnels)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist, access_change_ids, access_chemistry, access_maint_tunnels)

	rank_succesion_level = COMMAND_SUCCESSION_LEVEL

	dep_authority = list( MEDICAL )

/datum/job/cmo/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/cmo(H), slot_l_ear)
	switch(H.character.backpack)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/heads/cmo(H), slot_belt)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
	if(H.character.backpack == 1)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/labcoat/cmo(H), slot_wear_suit)
	H.equip_to_slot_or_qdel(new /obj/item/device/flashlight/pen(H), slot_s_store)

	return 1

/datum/job/cmo/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bio_cmo"), ICON_OVERLAY)
	else
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
	switch(backpack)
		if(2)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
		if(3)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
		if(4)			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
