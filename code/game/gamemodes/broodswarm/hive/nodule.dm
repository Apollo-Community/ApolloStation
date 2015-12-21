/obj/machinery/broodswam/nodule
	name = "nodule"
	desc = "It looks like there's something inside."
	var/mob/living/occupant = null // Whats inside?



/obj/machinery/broodswam/nodule/healer
	var/heal_rate = 6
	var/mend_prob = 50

/obj/machinery/broodswam/nodule/healer/process()
	if( heal_occupant() == 2 )
		occupant << "<span class='notice'>You feel fully healed, and crawl out of the pit.</span>"
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

/obj/machinery/broodswam/nodule/healer/proc/take_occupant( var/mob/M )
	if( !M || !istype( M ))
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src

	src.occupant = M

/obj/machinery/broodswam/nodule/healer/proc/eject_occupant()
	if( !occupant )
		return

	visible_message( "<span class='warning'>[occupant] bursts out from the [src]!</span>" )

	occupant.Move( get_turf( src ))
	occupant = null

	explode()

	return

/obj/machinery/broodswam/nodule/healer/proc/explode()
	new /obj/effect/gibspawner/human( get_turf( src ))
	qdel( src )
