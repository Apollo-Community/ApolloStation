//Food
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

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
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
	alt_titles = list("Cook", "Gardener")

	rank_succesion_level = 4


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.job == "Chef" || H.job == "Cook")
			H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
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
		else
			H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
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
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			return 1

/datum/job/chef/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/head.dmi', "chefhat"), ICON_OVERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apronchef"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)

	rank_succesion_level = 5

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/quartermaster(H), slot_belt)
//		H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/qm/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "poncho"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/cargo(H), slot_belt)
//		H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/cargo_tech/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "cargotech_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "flat_cap"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
	alt_titles = list("Drill Technician","Prospector")

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_cargo (H), slot_l_ear)
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/shaftminer(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
//		H.equip_to_slot_or_qdel(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/crowbar(H), slot_l_hand)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/crowbar(H), slot_in_backpack)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
		return 1

/datum/job/mining/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "bearpelt"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

//Griff //BS12 EDIT
/*
/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/clown(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/toy/waterflower(H), slot_in_backpack)
		H.mutations.Add(CLUMSY)
		return 1


/datum/job/mime
	title = "Mime"
	flag = MIME
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
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
		//H.verbs += /client/proc/mimewall
		H.mind.special_verbs += /client/proc/mimespeak
		//H.mind.special_verbs += /client/proc/mimewall
		H.miming = 1
		return 1
*/

/datum/job/entertainer
	title = "Entertainer"
	flag = ENTERTAINER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)
	alt_titles = list("Mime", "Jester")

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.job == "Jester")
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
		else if(H.job == "Mime")
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
		else
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
			return 1

/datum/job/entertainer/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "entertainer_s")
	clothes_s.Blend(new /icon('icons/mob/head.dmi', "entertainerhat"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

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

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
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

/datum/job/janitor/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bio_janitor"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist")

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/librarian(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/barcodescanner(H), slot_l_hand)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1

/datum/job/librarian/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "hairflower"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the captain"
	selection_color = "#dddddd"
	access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_lawyer, access_court, access_sec_doors)

	rank_succesion_level = 4

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/suit/storage/toggle/internalaffairs(H), slot_wear_suit)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses/big(H), slot_glasses)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/lawyer(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

		H.implant_loyalty(H)


		return 1

/datum/job/lawyer/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "internalaffairs_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
