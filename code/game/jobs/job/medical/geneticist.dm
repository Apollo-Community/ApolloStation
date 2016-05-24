/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_id = MEDICAL
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_research)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research)

/datum/job/geneticist/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_medsci(H), slot_l_ear)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
	H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_qdel(new /obj/item/device/pda/geneticist(H), slot_belt)
	switch(H.character.backpack)
		if(1) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/genetics(H), slot_back)
		if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_gen(H), slot_back)
		if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/geneticist/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "surgeon"), ICON_OVERLAY)
	else
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s