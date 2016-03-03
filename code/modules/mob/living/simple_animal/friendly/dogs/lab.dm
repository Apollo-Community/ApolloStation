/mob/living/simple_animal/dog/labrador
	name = "\improper labrador"
	real_name = "labrador"
	desc = "It's a labrador."
	icon = 'icons/mob/animal.dmi'
	icon_state = "labrador"
	icon_living = "labrador"
	icon_dead = "labrador_dead"

/mob/living/simple_animal/dog/labrador/beaker
	name = "\improper Beaker"
	real_name = "Beaker"
	gender = MALE
	desc = "That's Beaker, the research lab."
	var/bff = null // The person Sirius protects

	icon_state = "lab_beaker"
	icon_living = "lab_beaker"
	icon_dead = "lab_beaker_dead"

/mob/living/simple_animal/dog/labrador/beaker/New()
	..()
	for( var/mob/living/carbon/human/M in living_mob_list )
		if (M.mind)
			if (M.mind.assigned_role == "Research Director")
				bff = M
				break
