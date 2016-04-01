/datum/contract/propaganda
	title = "Spread Propaganda"
	desc = "Have you heard of our lord and savior Space Jesus?"
	time_limit = 1200
	max_workers = 1 // any more makes checking completion a nightmare
	reward = 600

	var/to_spread = 0
	var/propaganda = null
	var/list/texts = list(
		{"<center><img src = logo-anti.png><br><B>Deceased crew refused proper funeral!</B></center><hr>
		After NanoTrasen's exploits in a mining field in Tau Ceti, the sheer idiocy of the system's Central Command's
		orders caused <B>13</B> crew deaths! These men and women did not even deserve to die, but NanoTrasen has now
		refused to cover for their funerals. Rumors are also about that NanoTrasen <B>took 4 of the corpses for ILLEGAL
		research</B>! Don't stand by and allow these <B>criminals</B> to escape. Make your voices heard!"},

		{"<center><img src = logo-anti.png><br><B>NanoTrasen leaves crew on depressurized station!</B></center><hr>
		A NanoTrasen research station crew was recently <B>left for dead</B> on a depressurized station after they
		accidentally passed through an asteroid belt. When asked for a comment, NanoTrasen justified their actions by
		saying <B>they didn't want to waste resources on such a trivial matter</B>. How can any NanoTrasen employee
		feel safe when their employers show so clearly that they <B>don't care about their crew's lives</B>?"}
	)

	var/list/bonus_areas = list( // placing your propaganda here gives a small reward bonus
		/area/hallway/primary,
		/area/crew_quarters/bar,
		/area/bridge,
		/area/hallway/secondary/exit
	)

/datum/contract/propaganda/New()
	. = ..()
	if(!.)	return

	propaganda = get_propaganda()

	if(!propaganda)
		qdel(src)
		return

	to_spread = rand(3,8)
	reward = 150 * to_spread

	set_details()

/datum/contract/propaganda/start(var/mob/living/worker)
	..()

	var/obj/item/weapon/paper/P = new(get_turf(worker))
	P.name = "information pamphlet"
	P.info = propaganda
	var/obj/item/weapon/tape_roll/T = new(get_turf(worker))

	worker.put_in_any_hand_if_possible(P)
	worker.put_in_any_hand_if_possible(T)

	worker << "The contract author has teleported the gear you will need to complete the contract. You will receive a bonus if you hang up the propaganda in the following areas:"
	for(var/area in bonus_areas)
		var/area/A = locate(area)
		if(A)
			worker << "\The [A.name]"
	worker << "You can photocopy the pamphlets if you need more."

/datum/contract/propaganda/set_details()
	desc = "[pick(list("We want to put NanoTrasen in a bad light in front of their own crew", "It's time for NanoTrasen's crimes to become known to all"))]. Hang up at least [to_spread] of the pamphlets we will teleport to you around the station in different areas (not in maintenance)."
	informal_name = "Hang up anti-NT propaganda pamphlets around the station"

/datum/contract/propaganda/check_completion()
	if(workers.len == 0)	return

	var/list/area/areas = typesof(/area/maintenance) // maintenance propaganda is cheap as hell and doesn't count
	var/pamphlet_count = 0
	var/bonus_multiplier = 1
	for(var/obj/item/weapon/ducttape/T in world)
		var/area/A = get_area(T)
		if(T.stuck && istype(T.stuck, /obj/item/weapon/paper) && isturf(T.loc))
			var/obj/item/weapon/paper/P = T.stuck
			if(findtext(P.info, propaganda) && !(A.type in areas))
				areas += A.type
				pamphlet_count++
				for(var/area in bonus_areas)
					if(istype(A, area))	bonus_multiplier += 0.1 // 10% increase in reward per bonus area

	if(pamphlet_count >= to_spread)
		reward *= bonus_multiplier
		end(1, workers[1])

/datum/contract/propaganda/proc/get_taken_texts()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/propaganda/C in (faction.contracts - src))
		if(istype(C) && C.propaganda)	taken += C.propaganda
	return taken

/datum/contract/propaganda/proc/get_propaganda()
	texts -= get_taken_texts()
	return (texts.len > 0 ? pick(texts) : null)