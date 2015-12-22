/obj/machinery/broodswam/nodule
	name = "nodule"
	desc = "It looks like there's something inside."
	var/mob/living/occupant = null // Whats inside?
	icon = 'icons/obj/broodswarm.dmi'
	icon_state = "nodule"

/obj/machinery/broodswam/nodule/proc/take_occupant( var/mob/M )
	if( !M || !istype( M ))
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src

	src.occupant = M

/obj/machinery/broodswam/nodule/proc/eject_occupant()
	if( !occupant )
		return

	visible_message( "<span class='warning'>[occupant] bursts out from the [src]!</span>" )

	occupant.Move( get_turf( src ))
	occupant = null

	explode()

	return

/obj/machinery/broodswam/nodule/proc/explode()
	new /obj/effect/gibspawner/human( get_turf( src ))
	qdel( src )


/* ---- HEALER NODULE ---- */
/obj/machinery/broodswam/nodule/healer
	var/heal_rate = 6
	var/mend_prob = 50

/obj/machinery/broodswam/nodule/healer/process()
	if( heal_occupant() == 2 )
		occupant << "<span class='notice'>You feel fully healed, and emerge from the [src]!</span>"
		eject_occupant()
		return

/obj/machinery/broodswam/nodule/healer/proc/heal_occupant()
	if( !ishuman( occupant ))
		return 0

	var/mob/living/carbon/human/H = occupant

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

	//next mend broken bones
	for(var/datum/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					H << "<span class='broodswarm'>You feel something mend itself inside your [E.display_name]...</span>"
			return 1

	return 2

/obj/machinery/broodswam/nodule/healer/take_occupant( var/mob/M )
	..()

	if( ishuman( occupant ))
		// shut down various types of badness
		var/mob/living/carbon/human/H = occupant

		H.setToxLoss(0)
		H.setOxyLoss(0)
		H.setCloneLoss(0)
		H.setBrainLoss(0)
		H.SetParalysis(0)
		H.SetStunned(0)
		H.SetWeakened(0)

		// shut down ongoing problems
		H.radiation = 0
		H.nutrition = 400
		H.bodytemperature = T20C
		H.sdisabilities = 0
		H.disabilities = 0

		// fix blindness and deafness
		H.blinded = 0
		H.eye_blind = 0
		H.eye_blurry = 0
		H.ear_deaf = 0
		H.ear_damage = 0

		// remove chemical reagents
		H.reagents.clear_reagents()
		H.restore_blood()

		// remove the character from the list of the dead
		if(H.stat == 2)
			dead_mob_list -= H
			living_mob_list += H
			H.tod = null
			H.timeofdeath = 0

		// restore us to conciousness
		H.stat = CONSCIOUS

		// make the icons look correct
		H.regenerate_icons()
		H.hud_updateflag |= 1 << HEALTH_HUD
		H.hud_updateflag |= 1 << STATUS_HUD
