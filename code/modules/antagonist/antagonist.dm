/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take datum/contracts, and are rewarded for successful completion. 
*/

/datum/antagonist
	var/name = "Antagonist"
	var/greeting = "You are an antagonist." // Shown when the antag is setup, informing them they're an antagonist
	var/obligatory_contracts = 1 // How many contracts the antagonist is forced to take from round start
	var/datum/contract/list/active_contracts = list() // Currently active contracts for the antagonist

	var/datum/contract/list/completed_contracts = list()
	var/datum/mind/antag = null

/datum/antagonist/New(var/datum/mind/us)
	..()

	antag = us
	// setup() done in postsetup so that there's actually contracts to pick

/datum/antagonist/proc/setup()
	for(var/i = 0; i < obligatory_contracts; i++)
		var/datum/contract/C = pick(uplink.contracts)
		while((C in active_contracts) || isnull(C))
			C = pick(uplink.contracts)
		// no self-harm
		if(istype(C, /datum/contract/kill))
			var/datum/contract/kill/K = C
			var/list/kill_contracts = uplink.get_contracts(/datum/contract/kill)
			if(kill_contracts.len > 0)
				while((K in active_contracts) || isnull(K) || K.target == antag)
					K = pick(kill_contracts)
				C = K
			else
				while((C in active_contracts) || isnull(C))
					C = pick(uplink.contracts)

		C.start(antag.current)

	antag.character.temporary = 1

	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	if(active_contracts.len > 0)
		antag.current << "Your employer has signed the following contracts in your name:"
		for(var/datum/contract/C in active_contracts)
			var/list/amounts = list()
			amounts["hrs"] = Floor((C.time_limit/10)/3600)
			amounts["min"] = ((C.time_limit/10)/60) % 60
			amounts["sec"] = (C.time_limit/10) % 60
			var/time = ""
			if(amounts["hrs"] > 0)
				time += "[amounts["hrs"]] hours"
			if(amounts["min"] > 0)
				time += "[amounts["sec"] > 0 ? ", " : (amounts["hrs"] > 0 ? " and " : "")][amounts["min"]] minutes"
			if(amounts["sec"] > 0)
				time += "[(amounts["hrs"] > 0 || amounts["min"] > 0) ? " and " : ""][amounts["sec"]] seconds"
			antag.current << "<B>[C.title]</B>\n<I>[C.desc]</I>\nYou have [time] to complete the contract."
	else
		antag.current << "Your employer has not signed any contracts in your name."
	antag.current << "\n"

	equip()

// Equip the antagonist here
/datum/antagonist/proc/equip()
	return
	
/datum/antagonist/proc/contract_start(var/datum/contract/contract)
	active_contracts += contract

/datum/antagonist/proc/contract_ended(var/datum/contract/contract, var/success = 0)
	active_contracts -= contract
	if(success)
		completed_contracts += contract
