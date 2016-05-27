/datum/job/senior_engineer
    title = "Senior Engineer"
    flag = SENIOR_ENGINEER
    department_id = ENGINEERING
    faction = "Station"
    total_positions = 3
    spawn_positions = 3
    supervisors = "the chief engineer"
    selection_color = "#fff5cc"
    access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
                        access_heads, access_construction)
    minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
                        access_heads, access_construction)

    alt_titles = list("Engine Specialist","Atmospherics Specialist","Senior Electrician","Senior Technician")
    rank_succesion_level = 5

/datum/job/senior_engineer/equip(var/mob/living/carbon/human/H)
    if(!H)  return 0
    if(H.job == "Atmospherics Specialist")
        H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
        switch(H.character.backpack)
            if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
            if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
            if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/atmospheric_technician(H), slot_w_uniform)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
        H.equip_to_slot_or_qdel(new /obj/item/device/pda/atmos(H), slot_l_store)
        H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/belt/utility/atmostech/(H), slot_belt)
    else if(H.job == "Engine Specialist")
        H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
        switch(H.character.backpack)
            if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
            if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
            if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/sm_proof(H), slot_gloves)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/orange(H), slot_shoes)
        H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/head/hardhat(H), slot_head)
        H.equip_to_slot_or_qdel(new /obj/item/device/t_scanner(H), slot_r_store)
        H.equip_to_slot_or_qdel(new /obj/item/device/pda/engineering(H), slot_l_store)
    else
        H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
        switch(H.character.backpack)
            if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
            if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
            if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/orange(H), slot_shoes)
        H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
        H.equip_to_slot_or_qdel(new /obj/item/clothing/head/hardhat(H), slot_head)
        H.equip_to_slot_or_qdel(new /obj/item/device/t_scanner(H), slot_r_store)
        H.equip_to_slot_or_qdel(new /obj/item/device/pda/engineering(H), slot_l_store)

    if(H.character.backpack == 1)
        H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
    else
        H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
    return 1

/datum/job/senior_engineer/make_preview_icon( var/backpack , var/job , var/gender )
	var/icon/clothes_s = null

	if(job == "Atmospherics Specialist")
		clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if(prob(1))			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "firesuit"), ICON_OVERLAY)
	else
		clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
		if(prob(1))			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "hazard"), ICON_OVERLAY)


	clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)

	switch(backpack)
		if(2)            clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
		if(3)            clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
		if(4)            clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
