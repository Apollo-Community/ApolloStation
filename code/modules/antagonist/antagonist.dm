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

	// so fucking ugly but i cba to think of another solution
	if(faction.contracts.len == 0)
		faction.update_contracts()

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

	var/datum/money_account/A = find_account(antag.current)
	A.money += faction.start_cash

	antag.character.temporary = 1

	// greet the antagonist and give them any info concerning their task(s)

	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	antag.current << "<B><font size=2 color=red>You are working for \The [faction.name].</font></B>"
	antag.current << "Your employer has provided you with an extra $[faction.start_cash] to purchase equipment with."
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

	if(active_contracts.len > 0)
		antag.current << "Your employer has signed the following contracts in your name:"
		for(var/datum/contract/C in active_contracts)
			var/time = C.formatted_time()
			antag.current << "<B>[C.title]</B>\n<I>[C.desc]</I>\nYou have [time] to complete the contract."
	else
		antag.current << "Your employer has not signed any contracts in your name."
	antag.current << "" // newline

	equip()

// Equip the antagonist here
/datum/antagonist/proc/equip()
	return
	
/datum/antagonist/proc/contract_start(var/datum/contract/C)
	active_contracts += C

/datum/antagonist/proc/contract_ended(var/datum/contract/C, var/success = 0)
	faction.contract_ended(C)
	active_contracts -= C
	if(success)
		completed_contracts += C