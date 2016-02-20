/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_id = SYNTHETIC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_playtime = 1
	alt_titles = list("Android", "Robot")

	rank_succesion_level = BORG_SUCCESSION_LEVEL

/datum/job/cyborg/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	return 1

/datum/job/cyborg/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	clothes_s.Blend(new /icon('icons/mob/suit.dmi', "cardborg"), ICON_OVERLAY)
	clothes_s.Blend(new /icon('icons/mob/head.dmi', "cardborg_h"), ICON_OVERLAY)
	if(backpack == 2)
		clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
	else if(backpack == 3 || backpack == 4)
		clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s