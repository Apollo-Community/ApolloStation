/proc/broodmother_exists(var/ignore_self,var/mob/living/carbon/human/self)
	for(var/mob/living/carbon/human/Q in living_mob_list)
		if(self && ignore_self && self == Q)
			continue
		if(Q.species.name != "Broodmother")
			continue
		if(!Q.key || !Q.client || Q.stat)
			continue
		return 1
	return 0

/datum/species/broodswarm
	name = "Broodswarm"
	name_plural = "Broodswarm"

	default_language = "Broodtongue"
	language = "Broodmind"
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)
	hud_type = /datum/hud_data/alien
	rarity_value = 3

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = 2

	eyes = "blank_eyes"

	brute_mod = 0.5 // Hardened carapace.
	burn_mod = 2    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	flags = IS_RESTRICTED | NO_BREATHE | NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON

	death_message = "lets out an unearthly screech and falls limp!"
	death_sound = 'sound/voice/hiss6.ogg'

	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100

	var/blotch_heal_rate = 3     // Health regen on the blotch
	var/global/brood_points = 0 // Used for hive and swarm upgrades
	var/global/swarm_number = 0 // Total population of the broodswarm

/datum/species/broodswarm/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message("<span class='notice'>\The [H] strokes [target].</span>", \
					  "<span class='notice'>You stroke [target].</span>")

/datum/species/broodswarm/handle_post_spawn(var/mob/living/carbon/human/H)
	if(H.mind)
		H.mind.assigned_role = "Broodswarm"
		H.mind.special_role = "Broodswarm"

	swarm_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "broodling ([swarm_number])"
	H.name = H.real_name

	..()

/datum/species/broodswarm/handle_environment_special(var/mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(!T) return

	if(locate(/atom/movable/cell/blotch) in T)
		regenerate(H)

	..()

/datum/species/broodswarm/proc/regenerate(var/mob/living/carbon/human/H)
	var/heal_rate = blotch_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = blotch_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(5))
			H << "<span class='broodswarm'>A membrane forms over your wounds...</span>"
		return 1

	//next internal organs
	for(var/datum/organ/internal/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				H << "<span class='broodswarm'>Your [I.parent_organ] begins to rapidly regenerate...</span>"
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/datum/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					H << "<span class='broodswarm'>You feel something mend itself inside your [E.display_name]...</span>"
			return 1

	return 0

/datum/species/broodswarm/broodmother
	name = "Broodmother"
	slowdown = 1
	rarity_value = 5

	icobase = 'icons/mob/human_races/broodswarm/broodmother.dmi'
	icon_template = 'icons/mob/human_races/broodswarm/broodmother.dmi'

	damage_overlays = 'icons/mob/human_races/broodswarm/dam_broodmother.dmi'
	damage_mask = 'icons/mob/human_races/broodswarm/dam_broodmother.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain,
		"tumor" =			/datum/organ/internal/broodswarm,
	)

	inherent_verbs = list()

/datum/species/broodswarm/broodmother/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official broodmother exists at any point.

	H.pixel_x = -16

	if(!broodmother_exists(1,H))
		H.real_name = "Broodmother"
		H.name = H.real_name
	else
		H.real_name = "Brooddaughter"
		H.name = H.real_name

/datum/hud_data/broodswarm
	icon = 'icons/mob/screen1_alien.dmi'
	has_a_intent =  1
	has_m_intent =  1
	has_warnings =  1
	has_hands =     1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  1
	has_nutrition = 1
	has_bodytemp =  1
	has_internals = 0

	gear = list()