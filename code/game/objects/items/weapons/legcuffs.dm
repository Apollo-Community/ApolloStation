/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

	suicide_act(mob/user)
		viewers(user) << "<span class='alert'><b>[user] is putting the [src.name] on \his head! It looks like \he's trying to commit suicide.</b></span>"
		return (BRUTELOSS)

/obj/item/weapon/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		user << "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/human/H = AM
				if(H.m_intent == "run")
					armed = 0
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed()
					H << "<span class='alert'><B>You step on \the [src]!</B></span>"
					feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
					for(var/mob/O in viewers(H, null))
						if(O == H)
							continue
						O.show_message("<span class='alert'><B>[H] steps on \the [src].</B></span>", 1)

					// no safety bear traps. this shit fucks your leg up
					var/datum/organ/external/r_leg/leg = H.get_organ("r_leg")
					if(leg)	leg.take_damage(rand(10,21))
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20
	..()

/obj/item/weapon/legcuffs/beartrap/viper
	name = "viper's coil"
	desc = "A \"bear trap\" with sharp, thick needles and razor blades coated in a thick liquid."
	var/has_poison = 1

/obj/item/weapon/legcuffs/beartrap/viper/Crossed(var/mob/living/carbon/human/M)
	..()

	if(istype(M) && M.legcuffed)
		// you could probably argue that it snaps around the foot, but i think that'd be a very tiny bear trap
		var/datum/organ/external/r_leg/leg = M.get_organ("r_leg")
		if(leg)
			M << "<span class='alert'>You feel your leg above your ankle being pierced and cut up! [has_poison ? "<b>It burns like hell!</b>" : ""]</span>"
			var/emote_sound = M.species.voice_sounds.getScream(gender)
			if(emote_sound)	playsound(loc, emote_sound, 80, M.species.mod_sound)

			leg.take_damage(rand(6, 12))
			if(has_poison)
				has_poison = 0
				M.reagents.add_reagent("toxin", 3.3)
				M.Stun(5)
				M.Weaken(6)