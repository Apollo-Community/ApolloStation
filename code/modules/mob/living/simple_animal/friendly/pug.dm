/mob/living/simple_animal/pug
 name = "pug"
 desc = "The best friend of the human race!"
 icon = 'icons/mob/Pug_Fox sprites.dmi'
 icon_state = "pug"
 icon_living = "pug"
 icon_dead = "pug_dead"

 speak = list("Growl!", "Woof!!")
 speak_emote = list("growls", "bites air", "")
 emote_hear = list("growls", "bites air", "howls")
 emote_see = list("shakes its head", "licks its nose")
 speak_chance = 1
 turns_per_move = 6
 response_help   = "cuddles"
 response_disarm = "shoves"
 response_harm   = "kicks"
 minbodytemp = 200
 speed = 4

 health = 40
 maxHealth = 40
 harm_intent_damage = 4
 melee_damage_lower = 10
 melee_damage_upper = 15
 attacktext = "bitten"