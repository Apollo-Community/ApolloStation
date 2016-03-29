/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take /datum/contracts, and are rewarded for successful completion. 
*/

/datum/antagonist
	var/name = "Antagonist" 							// Name of the type of antagonist (Changeling, traitor, etc.)
	var/greeting = "You are an antagonist." 			// Shown when the antag is setup, informing them they're an antagonist
	var/obligatory_contracts = 1 						// How many contracts the antagonist is forced to take from round start
	var/list/datum/contract/active_contracts = list() 	// Currently active contracts for the antagonist

	var/datum/faction/syndicate/faction = null // Defining this (type path) in the antagonist datum will force all antagonists of that type to be part of this faction
	var/list/datum/contract/completed_contracts = list()
	var/datum/mind/antag = null

/datum/antagonist/New(var/datum/mind/us)
	..()

	antag = us

/datum/antagonist/proc/setup()
	if(faction)
		faction_controller.join_faction(antag, faction)
	else
		faction_controller.get_syndie_faction(antag)

	if(!faction) // we need a faction
		message_admins("[antag.key]/([antag.current.real_name]) was made an antagonist, but failed to get a faction.")
		antag.antagonist = null
		ticker.mode.traitors -= antag
		qdel(src)
		return 0

	antag.character.temporary = 1

	// greet the antagonist and give them any info concerning their task(s)

	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	antag.current << "<B><font size=2 color=red>You are working for \The [faction.name].</font></B>"
	if(!ticker.contracts_made)
		antag.current << "You are a sleeper cell agent, and your employer has recently ordered you to <B>stand by for further instructions</B>."
		antag.current << "" // newline

	switch(faction.friendly_identification)
		if(FACTION_ID_PHRASE)
			antag.current << "\The [faction.name] has provided all its agents with the following code phrases to identify other agents:"
			antag.current << "<B>[list2text(faction.phrase, ", ")]</B>"
		if(FACTION_ID_COMPLETE)
			if((faction.members.len - 1) > 0)
				antag.current << "\The [faction.name] has provided all its agents with the identity of their fellow agents. Your co-workers are as follows:"
				for(var/datum/mind/M in (faction.members - antag))
					antag.current << "<B>[M.current.real_name]</B>, [station_name] [M.assigned_role]"
			else
				antag.current << "\The [faction.name] has informed you that <B>you are the only active [faction.name] agent on [station_name]</B>."
	antag.current << "" // newline

	if(ticker.contracts_made) // for antags that are created mid-round, after the contracts have been made available
		pick_contracts()
		antag.current << "" // newline

	equip()

/datum/antagonist/proc/pick_contracts()
	for(var/i = 0; i < obligatory_contracts; i++)
		var/datum/contract/C = pick(faction.contracts)
		while((C in active_contracts) || isnull(C) || !C.can_accept(antag.current))
			C = pick(faction.contracts)
		// no self-harm. try to get a new kill contract, though
		if(istype(C, /datum/contract/kill))
			var/datum/contract/kill/K = C
			var/list/kill_contracts = faction.get_contracts(/datum/contract/kill) - active_contracts
			if(kill_contracts.len > 0)
				while((K in active_contracts) || isnull(K) || !K.can_accept(antag.current))
					kill_contracts -= K
					K = pick(kill_contracts)
				C = K
			else
				while((C in active_contracts) || isnull(C) || !C.can_accept(antag.current))
					C = pick(faction.contracts)

		C.start(antag.current)

	antag.current << ""
	antag.current << "<B><font size=3 color=red>\The [faction.name] has decided on your orders.</font></B>"
	if(active_contracts.len > 0)
		antag.current << "Your employers have signed the following contracts in your name:"
		for(var/datum/contract/C in active_contracts)
			var/time = worldtime2text(world.time + C.time_limit)
			antag.current << "<B>[C.title]</B>\n<I>[C.desc]</I>\nYou have until [time], station time to complete the contract."
	else
		antag.current << "You are declared autonomous. You may accept contracts freely, but are not obligated to do so."
	antag.current << "<B>Contracts are now available from your Uplink.</B>"
	antag.current << ""

// Equip the antagonist here
/datum/antagonist/proc/equip()
	return
	
/datum/antagonist/proc/contract_start(var/datum/contract/C)
	active_contracts += C

/datum/antagonist/proc/contract_ended(var/datum/contract/C, var/success = 0)
	active_contracts -= C
	if(success)
		completed_contracts += C

	var/obj/item/I = locate(/obj/item/device/pda) in antag.current.contents

	if(antag.character.uplink_location == "Headset" && locate(/obj/item/device/radio) in antag.current.contents)
		I = locate(/obj/item/device/radio) in antag.current.contents

	if(!I)	return
	if(istype(I, /obj/item/device/radio))
		antag.current << "<span class='notice'>You feel your headset vibrate.</span>"
	else
		antag.current << "<span class='notice'>You feel your PDA vibrate.</span>"