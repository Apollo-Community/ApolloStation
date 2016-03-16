/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list("Monkey")

/mob/living/carbon/human/monkey/punpun/New()
	..()
	spawn(1)
		name = "Pun Pun"
		real_name = name
		maxHealth = 100
		w_uniform = new /obj/item/clothing/under/punpun(src)

/mob/living/carbon/human/monkey/punpun/Life()
	..()
	//Pun pun gets heals!
	for (var/datum/organ/external/O in organs)
		if(prob(25))
			O.status &= ~ORGAN_BROKEN
			O.status &= ~ORGAN_BLEEDING
			O.wounds.Cut()

/mob/living/carbon/human/monkey/punpun/attackby(obj/W, mob/user)
	..()
	handle_attack(user)

/mob/living/carbon/human/monkey/punpun/attack_hand(mob/user)
	..()
	handle_attack(user)

/mob/living/carbon/human/monkey/punpun/proc/handle_attack(mob/user,force_fight = 0)
	var/attack_serverity = 0
	walk(src,0)		//Incase punpun gets stuck or has a new target
	if(!force_fight)
		switch(health)
			if(90 to 100)	return
			if(80 to 90)	visible_message("<span class='warning'>[src] glares at [user] intently.</span>")
			if(70 to 80)	visible_message("<span class='danger'>[src] gives [user] a death stare.</span>")
			if(50 to 70)	attack_serverity = 1
			if(25 to 50)	attack_serverity = 2
			else			attack_serverity = 3
	else
		attack_serverity = force_fight
		
	if(lastattacker == user)	attack_serverity++

	if(!attack_serverity)	return
	/*									Punpun going to hunt you down and get you now.
	if(get_dist(t_user, t_src) > 6)		//even punpun is only /human/
		step_towards(src, user)			//Moves punpun towards the target.
		return
	*/
	if(last_special > world.time)	return
	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)	return			//Gotta give am a chance.

	last_special = world.time + 35		// Gives punpun some nice relaxing down time.

	visible_message("<span class='warning'><b>\The [src]</b> charges and leaps at [user]!</span>")
	walk_towards(src,get_turf(user),0,7)		//throw_at doesn't seem to work here, so had to improvise

	spawn(5)
		user.Weaken(5)

		if(attack_serverity == 1)	 return
		if(!istype(user,/mob/living/carbon/human))	return

		var/mob/living/carbon/human/H = user

		if(attack_serverity == 2)
			visible_message("<span class='warning'><b>[src]</b> bites at [user]'s body!</span>")
			H.apply_damage(10,BRUTE)
		else if(attack_serverity == 3)
			visible_message("<span class='danger'><b>[src]</b> rips viciously at [user]'s body with its claws!</span>")
			H.apply_damage(30,BRUTE)
			if(H.stat == 2)
				visible_message("<span class='danger'><b>[src]</b> rips [user]'s body to shreads with its claws!</span>")
				H.gib()			// Don't mess with the puns.

/mob/living/carbon/human/monkey/ed/New()
	..()
	spawn(1)
		name = "Ed"
		real_name = name
		w_uniform = new /obj/item/clothing/under/rank/cargotech(src)
		head = new /obj/item/clothing/head/soft(src)
