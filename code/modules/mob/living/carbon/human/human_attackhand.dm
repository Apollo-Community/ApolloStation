/mob/living/carbon/human/attack_hand(mob/living/M as mob)
	if(status_flags & GODMODE)	return			//godmode takes no damage!

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/datum/organ/external/temp = H.organs_by_name["r_hand"]
		if(H.hand)
			temp = H.organs_by_name["l_hand"]
		if(temp && !temp.is_usable())
			H << "<span class='alert'>You can't use your [temp.display_name].</span>"
			return

	if( istype( M, /mob/living/simple_animal/rodent/rat/king ))
		var/mob/living/simple_animal/rodent/rat/king/K = M
		if( stat && K.canEatCorpse() && !( SKELETON in mutations ))
			src.visible_message("<span class='warning'>\The [K] swarms the body of [src], ripping flesh from bone!</span>" )

			if( !do_after( K, 200 ))
				K << "<span class='warning'>You need to wait longer to consume the body of [src]!</span>"
				return 0

			src.visible_message("<span class='warning'>\The [K] consumed the body of [src]!</span>" )
			ChangeToSkeleton()
			return
		if( K.canSpreadDisease() )
			infect_virus2( src, K.rat_virus, 1 )

	..()

	// Should this all be in Touch()?
	if(istype(H))
		// no attacking if we're in an alien nest!
		for(var/obj/structure/bed/nest/N in get_turf(H.loc))
			if(N.buckled_mob == H)
				return

		if((H != src) && check_shields(0, H.name))
			visible_message("<span class='alert'><B>[H] attempted to touch [src]!</B></span>")
			return 0

		if(istype(H.gloves, /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='alert'><B>[H] has attempted to punch [src]!</B></span>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(H.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in H.mutations)
				damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("<span class='alert'><B>[H] has punched [src]!</B></span>")

			apply_damage(damage, HALLOSS, affecting, armor_block)
			if(damage >= 9)
				visible_message("<span class='alert'><B>[H] has weakened [src]!</B></span>")
				apply_effect(4, WEAKEN, armor_block)

			return

	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		C.spread_disease_to(src, "Contact")

	switch(M.a_intent)
		if(I_HELP)

			if(istype(H) && health < config.health_threshold_crit)

				if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
					H << "<span class='notice'><B>Remove your mask!</B></span>"
					return 0
				if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
					H << "<span class='notice'><B>Remove [src]'s mask!</B></span>"
					return 0

				var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = loc
				O.place = "CPR"
				requests += O
				spawn(0)
					O.process()
			else
				help_shake_act(M)
			return 1

		if(I_GRAB)
			if(M == src || anchored)
				return 0
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			if(buckled)
				M << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
			if(!G)	//the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			return 1

		if(I_HURT)
			if(src.species.name == "Wryn")
				if(src.handcuffed)
					if(!(locate(src.internal_organs_by_name["antennae"]) in src.internal_organs))	return
					var/turf/p_loc = M.loc
					var/turf/p_loc_m = src.loc

					M.visible_message("<span class='notice'>[M] begins to violently pull off [src]'s antennae.</span>")
					src << "<span class='alert'><B>[M] grips your antennae and starts violently pulling!<B></span>"
					do_after(src, 250)
					if(p_loc == M.loc && p_loc_m == src.loc)
						qdel(src.internal_organs_by_name["antennae"])
						src.remove_language("Wryn Hivemind")
						new /obj/item/organ/wryn/hivenode(M.loc)
						M << "<span class='notice'>You hear a loud crunch as you mercilessly pull off [src]'s antennae.</span>"
						src << "<span class='alert'><B>You hear a loud crunch as your antennae is ripped off your head by [M].</B></span>"
						src << "<span class='alert'><B>Its so quiet...</B></span>"
						src.character.hair_style = "Bald"
						src.update_hair()

						if(!in_unlogged(M))
							M.attack_log += text("\[[time_stamp()]\] <font color='red'>removed antennae [src.name] ([src.ckey])</font>")
							src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their antennae removed by [M.name] ([M.ckey])</font>")
							msg_admin_attack("[key_name(M)] removed [key_name(src)]'s antennae")
					return 0

			if(!istype(H))
				attack_generic(H,rand(1,3),"punched")
				return

			var/rand_damage = rand(1, 5)
			var/block = 0
			var/accurate = 0
			var/hit_zone = H.zone_sel.selecting
			var/datum/organ/external/affecting = get_organ(hit_zone)

			switch(src.a_intent)
				if(I_HELP)
					// We didn't see this coming, so we get the full blow
					rand_damage = 5
					accurate = 1
				if(I_HURT, I_GRAB)
					// We're in a fighting stance, there's a chance we block
					if(src.canmove && src!=H && prob(20))
						block = 1

			if (M.grabbed_by.len)
				// Someone got a good grip on them, they won't be able to do much damage
				rand_damage = max(1, rand_damage - 2)

			if(src.grabbed_by.len || src.buckled || !src.canmove || src==H)
				accurate = 1 // certain circumstances make it impossible for us to evade punches
				rand_damage = 5

			// Process evasion and blocking
			var/miss_type = 0
			var/attack_message
			if(!accurate)
				/* ~Hubblenaut
					This place is kind of convoluted and will need some explaining.
					ran_zone() will pick out of 11 zones, thus the chance for hitting
					our target where we want to hit them is circa 9.1%.

					Now since we want to statistically hit our target organ a bit more
					often than other organs, we add a base chance of 20% for hitting it.

					This leaves us with the following chances:

					If aiming for chest:
						27.3% chance you hit your target organ
						70.5% chance you hit a random other organ
						 2.2% chance you miss

					If aiming for something else:
						23.2% chance you hit your target organ
						56.8% chance you hit a random other organ
						15.0% chance you miss

					Note: We don't use get_zone_with_miss_chance() here since the chances
						  were made for projectiles.
					TODO: proc for melee combat miss chances depending on organ?
				*/
				if(prob(80))
					hit_zone = ran_zone(hit_zone)
				if(prob(15) && hit_zone != "chest") // Missed!
					if(!src.lying)
						attack_message = "[H] attempted to strike [src], but missed!"
					else
						attack_message = "[H] attempted to strike [src], but \he rolled out of the way!"
						src.set_dir(pick(cardinal))
					miss_type = 1

			if(!miss_type && block)
				attack_message = "[H] went for [src]'s [affecting.display_name] but was blocked!"
				miss_type = 2

			// See what attack they use
			var/datum/unarmed_attack/attack = null
			for(var/datum/unarmed_attack/u_attack in H.species.unarmed_attacks)
				if(!u_attack.is_usable(H, src, hit_zone))
					continue
				else
					attack = u_attack
					break
			if(!attack)
				return 0

			if(!attack_message)
				attack.show_attack(H, src, hit_zone, rand_damage)
			else
				H.visible_message("<span class='danger'>[attack_message]</span>")

			playsound(loc, ((miss_type) ? (miss_type == 1 ? attack.miss_sound : 'sound/weapons/thudswoosh.ogg') : attack.attack_sound), 25, 1, -1)
			if(!in_unlogged(H))
				H.attack_log += text("\[[time_stamp()]\] <font color='red'>[miss_type ? (miss_type == 1 ? "Missed" : "Blocked") : "[pick(attack.attack_verb)]"] [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[miss_type ? (miss_type == 1 ? "Was missed by" : "Has blocked") : "Has Been [pick(attack.attack_verb)]"] by [H.name] ([H.ckey])</font>")
				if(!issmall(src))
					msg_admin_attack("[key_name(H)] [miss_type ? (miss_type == 1 ? "has missed" : "was blocked by") : "has [pick(attack.attack_verb)]"] [key_name(src)]  (<A HREF='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</A>)")

			if(miss_type)
				return 0

			var/real_damage = rand_damage
			real_damage += attack.get_unarmed_damage(H)
			real_damage *= damage_multiplier
			rand_damage *= damage_multiplier
			if(HULK in H.mutations)
				real_damage *= 2 // Hulks do twice the damage
				rand_damage *= 2
			real_damage = max(1, real_damage)

			var/armour = run_armor_check(affecting, "melee")
			// Apply additional unarmed effects.
			attack.apply_effects(H, src, armour, rand_damage, hit_zone)

			// Finally, apply damage to target
			apply_damage(real_damage, BRUTE, affecting, armour, sharp=attack.sharp, edge=attack.edge)

		if(I_DISARM)
			if(!in_unlogged(M))
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")
				if(!issmall(src))
					msg_admin_attack("[key_name(M)] disarmed [key_name(src)] (<A HREF='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</A>)")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))

			if (istype(r_hand,/obj/item/weapon/gun) || istype(l_hand,/obj/item/weapon/gun))
				var/obj/item/weapon/gun/W = null
				var/chance = 0

				if (istype(l_hand,/obj/item/weapon/gun))
					W = l_hand
					chance = hand ? 40 : 20

				if (istype(r_hand,/obj/item/weapon/gun))
					W = r_hand
					chance = !hand ? 40 : 20

				if (prob(chance))
					visible_message("<spawn class=danger>[src]'s [W] goes off during struggle!")
					var/list/turfs = list()
					for(var/turf/T in view())
						turfs += T
					var/turf/target = pick(turfs)
					return W.afterattack(target,src)

			var/randn = rand(1, 100)
			if(!(species.flags & NO_SLIP) && randn <= 25)
				apply_effect(3, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message("<span class='alert'><B>[M] has pushed [src]!</B></span>")
				return

			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("<span class='alert'><b>[M] has broken [src]'s grip on [pulling]!</B></span>")
					talked = 1
					stop_pulling()

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = l_hand
					if(lgrab.affecting)
						visible_message("<span class='alert'><b>[M] has broken [src]'s grip on [lgrab.affecting]!</B></span>")
						talked = 1
					spawn(1)
						qdel(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("<span class='alert'><b>[M] has broken [src]'s grip on [rgrab.affecting]!</B></span>")
						talked = 1
					spawn(1)
						qdel(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					drop_item()
					visible_message("<span class='alert'><B>[M] has disarmed [src]!</B></span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='alert'><B>[M] attempted to disarm [src]!</B></span>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return

/mob/living/carbon/human/attack_generic(var/mob/user, var/damage, var/attack_message)

	if(!damage)
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [user.name] ([user.ckey])</font>")
	src.visible_message("<span class='danger'>[user] has [attack_message] [src]!</span>")

	var/dam_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin")
	var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
	var/armor_block = run_armor_check(affecting, "melee")
	apply_damage(damage, BRUTE, affecting, armor_block)
	updatehealth()
	return 1
