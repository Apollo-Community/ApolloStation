//Stand-in until this is made more lore-friendly.
/datum/species/broodswarm
	name = "Broodswarm"
	name_plural = "Broodswarm"

	default_language = "Xenomorph"
	language = "Hivemind"
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

	var/swarm_number = 0
	var/creep_heal_rate = 1     // Health regen on weeds.

/datum/species/broodswarm/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress [target] with your scythe-like arm.</span>")

/datum/species/broodswarm/handle_post_spawn(var/mob/living/carbon/human/H)

	if(H.mind)
		H.mind.assigned_role = "Brood"
		H.mind.special_role = "Brood"

	swarm_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	..()

/datum/species/broodswarm/handle_environment_special(var/mob/living/carbon/human/H)

	var/turf/T = H.loc
	if(!T) return
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment) return

	if(environment.gas["phoron"] > 0 || locate(/obj/effect/alien/weeds) in T)
		if(!regenerate(H))
			var/datum/organ/internal/xenos/phoronvessel/P = H.internal_organs_by_name["phoron vessel"]
			P.stored_phoron += weeds_phoron_rate
			P.stored_phoron = min(max(P.stored_phoron,0),P.max_phoron)
	..()

/datum/species/broodswarm/proc/regenerate(var/mob/living/carbon/human/H)
	var/heal_rate = creep_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = creep_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(5))
			H << "<span class='alium'>You feel a soothing sensation come over you...</span>"
		return 1

	//next internal organs
	for(var/datum/organ/internal/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				H << "<span class='alium'>You feel a soothing sensation within your [I.parent_organ]...</span>"
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/datum/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					H << "<span class='alium'>You feel something mend itself inside your [E.display_name].</span>"
			return 1

	return 0

/datum/species/broodswarm/drone
	name = "Xenomorph Drone"
	caste_name = "drone"
	weeds_phoron_rate = 15
	slowdown = 1
	rarity_value = 5

	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_drone.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"phoron vessel" =   /datum/organ/internal/xenos/phoronvessel/queen,
		"acid gland" =      /datum/organ/internal/xenos/acidgland,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"resin spinner" =   /datum/organ/internal/xenos/resinspinner,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_phoron,
		/mob/living/carbon/human/proc/evolve,
		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/broodswarm/drone/handle_post_spawn(var/mob/living/carbon/human/H)

	var/mob/living/carbon/human/A = H
	if(!istype(A))
		return ..()
	..()


/datum/species/broodswarm/queen/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
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
	has_pressure =  0
	has_nutrition = 0
	has_bodytemp =  0
	has_internals = 0

	gear = list(
		"o_clothing" =   list("loc" = ui_belt,      "slot" = slot_wear_suit, "state" = "equip",  "dir" = SOUTH),
		"head" =         list("loc" = ui_id,        "slot" = slot_head,      "state" = "hair"),
		"storage1" =     list("loc" = ui_storage1,  "slot" = slot_l_store,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "slot" = slot_r_store,   "state" = "pocket"),
		)