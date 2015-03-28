/mob/living/simple_animal/dog/german_shep
	name = "\improper german shepherd"
	real_name = "german shepherd"
	desc = "It's a german shepherd."
	icon_state = "german_shep"
	icon_living = "german_shep"
	icon_dead = "german_shep_dead"

/mob/living/simple_animal/dog/german_shep/ace
	name = "\improper Ace"
	real_name = "Ace"
	gender = MALE
	desc = "Hundreds of years of specialized breeding has led to this spectacle of a creature."
	var/bff = null // The person Ace protects

/mob/living/simple_animal/dog/german_shep/ace/New()
	for( var/mob/living/carbon/human/M in living_mob_list )
		if (M.mind)
			if (M.mind.assigned_role == "Head of Security")
				bff = M
				break
