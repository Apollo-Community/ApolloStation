// Code by xRev, and some copypasta'd parts :)

/mob/living/simple_animal/hostile/plasmoid
	name = "plasmoid newborn"
	desc = "It looks like a mass of arcane energy meshed together by the compression and heat of phoron. It looks fairly dangerous."
	icon_state = "plasmoid"
	icon_living = "plasmoid"
	icon_dead = "plasmoid_dead"
	speak_chance = 0
	turns_per_move = 8
	response_help = "touches the"
	response_disarm = "tries to shove the"
	response_harm = "ineffectively tries to hit the" //Plasmoids aren't damaged by fists.
	speed = 5
	maxHealth = 60
	health = 60
	faction = "plasmoids"
	var/alive = 1

	harm_intent_damage = 0
	melee_damage_lower = 5
	melee_damage_upper = 15
	var/poison_per_stab = 5
	var/poison_type = "phoron"
	attacktext = "injected"
	var/attacktext_ni = "hit" //attacktext for non-injectable mobs or objects
	attack_sound = 'sound/effects/knife_stab.ogg'

	minbodytemp = 0
	maxbodytemp = 0
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	min_oxy = 0
	max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	min_tox = 1
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 5

/mob/living/simple_animal/hostile/plasmoid/AttackingTarget()
	if(!Adjacent(target_mob))
		return

	src.do_attack_animation(target_mob)
	if(isliving(target_mob) && target_mob.reagents)
		var/mob/living/L = target_mob
		L.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
		target_mob.reagents.add_reagent(poison_type, poison_per_stab)
		return L
//feel the horrible code optimilization!
	if(isliving(target_mob) && !target_mob.reagents)
		var/mob/living/LNR = target_mob
		LNR.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext_ni)
		return LNR
	if(istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		M.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext_ni)
		return M
	if(istype(target_mob,/obj/spacepod))
		var/obj/spacepod/S = target_mob
		S.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext_ni)
		return S
	if(istype(target_mob,/obj/machinery/bot))
		var/obj/machinery/bot/B = target_mob
		B.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext_ni)
		return B

/mob/living/simple_animal/hostile/plasmoid/death()
	if(alive)
		icon_state = icon_dead
		density = 0
		alive = 0
		new/obj/item/weapon/shard/phoron( src.loc )
		return ..(deathmessage = "tears to pieces and falls to the ground.")

/mob/living/simple_animal/hostile/plasmoid/overlord
	name = "plasmoid overlord"
	desc = "It looks like a big mass of arcane energy meshed together by the compression and heat of phoron. It's slightly glowing. It looks really dangerous."
	icon_state = "plasmoid_big"
	icon_living = "plasmoid_big"
	icon_dead = "plasmoid_big_dead"
	turns_per_move = 12
	speed = 3
	maxHealth = 150
	health = 150

	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_stab = 10

	unsuitable_atoms_damage = 15