/mob/living/simple_animal/wolf
	name = "wolf"
	desc = "The ancestor of humanity's greatest friend!"
	icon = 'icons/mob/wolfsprite.dmi'
	icon_state = "german_shep"
	icon_living = "german_shep"
	icon_dead = "german_shep_dead"

	speak = list("Growl!", "Hrmpf!")
	speak_emote = list("growls", "bites air", "howls")
	emote_hear = list("growls", "bites air", "howls")
	emote_see = list("shakes its head", "licks its nose")
	speak_chance = 1
	turns_per_move = 6
	response_help   = "cuddles"
	response_disarm = "shoves"
	response_harm   = "kicks"
	minbodytemp = 200
	speed = 3

	health = 50
	maxHealth = 50
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "bitten"