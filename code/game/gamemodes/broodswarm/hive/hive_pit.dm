/*----------- HIVE PIT ------------*/
/obj/machinery/broodswam/large/hive_pit
	icon_state = "hive_pit"

	name = "pit"
	desc = "A dark, ominous pit which appears to be breathing. Whatever it is that lies at the bottom, you hope you never know."

	var/mob/living/occupant = null // Who is at the bottom of the pit?
	var/progress = 0 // how close is the occupant to becoming a member of the broodswarm?
	var/max_progress = 0
	var/progess_per_tick = 7
	var/brood_flesh = 0 // How much meat we have
	var/brood_flesh_max = 0
	var/heal_rate = 6 // how much health is restored each tick
	var/mend_chance = 50 // percent chance each tick to mend fractures

/obj/machinery/broodswam/large/hive_pit/New()
	..()

	if( !ticker.addToHive( src ))
		qdel( src )

/obj/machinery/broodswam/large/hive_pit/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin))	// ooo secretss
		user << "You throw the [W.name] into the pit, but feel like this isn't the time for that..."
		qdel(W)
	else if(istype(W, /obj/item/weapon/grab) && isbroodswarm( user ))
		if(!ismob(W:affecting))
			return

		if(src.occupant)
			user << "<span class='warning'>This pit already contains an animal.</span>"
			return

		for(var/mob/living/carbon/slime/M in range(1,W:affecting))
			if(M.Victim == W:affecting)
				user << "<span class='warning'>This animal will not fit into the pit. First remove the slimey one from its head."
				return

		visible_message( "<span class='warning'>You offer another animal to the hive.</span>",
						 "<span class='warning'>[user] throws [W:affecting:name] down into the pit.</span>" )

		take_occupant( W:affecting )
		src.add_fingerprint(user)

		qdel(W)

/obj/machinery/broodswam/large/hive_pit/process()
	if( !occupant )
		return

	if( isbroodswarm( occupant ))
		handle_brood()
		return

	if( ishuman( occupant ))
		handle_human()
		return

	handle_misc()

/obj/machinery/broodswam/large/hive_pit/attack_hand( mob/user )
	if( isbroodswarm( user )) // Only broodswarm willingly go into a pit
		if( transfer_meat_to( user ))
			user << "<span class='notice'>You retrieve the flesh from the pit.</span>"
		else
			take_occupant( user )
		return
	else if( ishuman( user ))
		if( !occupant )
			if( brood_flesh )
				user << "<span class='notice'>There is nothing but a pile of meat at the bottom of this pit.</span>"
			else
				user << "<span class='notice'>There is nothing at the bottom of this pit.</span>"
			return

		visible_message( "<span class='notice'>You start reaching down to pull out whatever is at the bottom!</span>",
						 "<span class='notice'>[user] is reaching down into the pit!</span>" )
		if( !do_after( user, 240 ))
			user << "<span class='notice'>You stop reaching down into the pit.</span>"
			return

		visible_message( "<span class='notice'>You manage to pull \the [occupant] out of the pit!</span>",
						 "<span class='notice'>[user] pulls \the [occupant] out of the pit!</span>" )
		eject_occupant()
		return

/obj/machinery/broodswam/large/hive_pit/proc/handle_brood()
	if( !isbroodswarm( occupant ))
		return

	if( heal_occupant() == 2 )
		occupant << "<span class='notice'>You feel fully healed, and crawl out of the pit.</span>"
		eject_occupant()
		return

/obj/machinery/broodswam/large/hive_pit/proc/handle_human()
	if( !occupant )
		return

	if( !occupant.client )
		consume_occupant()

	if( progress >= max_progress )
		transform_occupant()
		eject_occupant()
		progress = 0
		return

	progress = min( max_progress, progress+progess_per_tick )

/obj/machinery/broodswam/large/hive_pit/proc/handle_misc()
	consume_occupant()

/obj/machinery/broodswam/large/hive_pit/proc/transform_occupant()
	if( !occupant )
		return

	if( !ishuman( occupant ))
		eject_occupant()
		return

	var/mob/living/carbon/human/H = occupant
	H.set_species( "Broodmother" )

/obj/machinery/broodswam/large/hive_pit/proc/heal_occupant()
	if( !ishuman( occupant ))
		return 0

	var/mob/living/carbon/human/H = occupant

	var/heal_rate = 6
	var/mend_prob = 50

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(10))
			occupant << "<span class='broodswarm'>A membrane forms over your wounds...</span>"
		return 1

	//next internal organs
	for(var/datum/organ/internal/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(20))
				occupant << "<span class='broodswarm'>Your [I.parent_organ] begins to rapidly regenerate...</span>"
			return 1

	//next mend broken bones
	for(var/datum/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					occupant << "<span class='broodswarm'>You feel something mend itself inside your [E.display_name]...</span>"
			return 1

	return 2

/obj/machinery/broodswam/large/hive_pit/proc/consume_occupant()
	if( !occupant )
		return

	if( issilicon( occupant ) || ismachine( occupant ))
		occupant << "<span class='notice'>The pit seems to gag, and spits you back out!</span>"
		eject_occupant()
		return

	var/message = pick( "A terrible squealching sound emanates from the pit!",
						"It sounds like the [src] is chewing..." )
	visible_message( "<span class='warning'>[message]</span>" )

	if( ismouse( occupant ))
		brood_flesh += 5
	else if( isanimal( occupant ))
		brood_flesh += 10
	else if( isbroodswarm( occupant ))
		brood_flesh += 30
	else if( ishuman( occupant ))
		brood_flesh += 50

	qdel( occupant )
	occupant = null

/obj/machinery/broodswam/large/hive_pit/proc/eject_occupant()
	if( !occupant )
		return

	occupant.Move( get_turf( src ))
	occupant = null

	return

/obj/machinery/broodswam/large/hive_pit/proc/take_occupant( var/mob/M )
	if( !M || !istype( M ))
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src

	src.occupant = M

/obj/machinery/broodswam/large/hive_pit/proc/transfer_meat_to( var/mob/living/user )
	if( !istype( user ))
		return brood_flesh

	user.brood_flesh = src.brood_flesh
	src.brood_flesh = 0

	return user.brood_flesh
