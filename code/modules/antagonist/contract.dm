/datum/contract
	var/title = "Ordinary Contract" 	// Contract name/title
	var/desc = "Complete the contract" 	// Contract information, what is required to complete it?
	var/informal_name = ""				// A more informal version of the title. Used on round end when traitors are revealed
	var/time_limit = 3600 				// How long before the contract expires after it's put on the uplink (in seconds). 0 = no limit
	var/reward = 1000 					// Thaler reward
	var/min_notoriety = 0 				// The minimum amount of notoriety you need to take on the contract
	var/max_workers = 0 				// Max amount of agents who can have this contract at the same time. 0 for no limit
	var/max_contracts = 0				// The maximum amount of contracts of this type that can appear on the uplink. 0 for no limit
	var/list/affilation = list() 		// If you place names of factions here, this contract will only appear in the Uplink of agents of that faction
										// E.g. if you define it as list("Cybersun Industries"), only cybersun agents will get the contract in their Uplink

	var/datum/faction/syndicate/faction = null
	var/list/mob/living/workers = list()

	var/finished = 0
	var/completed = 0
	var/contract_start = 0
	var/time_elapsed = 0

/datum/contract/New(var/datum/faction/syndicate/F)
	..()
	// Just let the faction controller see if it's a notoriety-restricted contract
	if(ticker.current_state == 1)	return 0
	if(!F)	return 0

	// by deleting ourselves here, we'll be removed from the candidate list in the faction's update_contract
	if(affilation.len > 0 && !(F.name in affilation))
		qdel(src)
		return 0

	if(max_contracts)
		var/same_count = 0
		for(var/datum/contract/C in F.contracts)
			if(istype(C, src.type))
				same_count++
		if(same_count >= max_contracts)
			qdel(src)
			return 0
	
	faction = F
	workers = list()

	time_limit *= 10
	contract_start = world.time
	if(contract_ticker)
		contract_ticker.contracts += src

	return 1

// set title, desc, etc. here
/datum/contract/proc/set_details()
	return

/datum/contract/proc/can_accept(var/mob/living/M)
	if(!M.mind.antagonist)	return 0
	if(max_workers && workers.len > max_workers)	return 0
	if(M.mind.antagonist.notoriety < min_notoriety)	return 0
	return 1

// Start the contract for a new antag
/datum/contract/proc/start(var/mob/living/worker)
	if(can_accept(worker))
		workers[++workers.len] = worker
		worker.mind.antagonist.contract_start(src)

// End the contract
/datum/contract/proc/end(var/success = 0, var/mob/living/worker)
	time_elapsed = world.time - contract_start
	finished = 1
	completed = success

	for(var/mob/living/M in workers)
		M.mind.antagonist.contract_ended(src, success)
		if(worker)
			if(success & M == worker)
				reward(worker)
		else if(success)
			reward(M)


	faction.contract_ended(src)
	contract_ticker.contracts -= src

// Check if the contract is completed.
/datum/contract/proc/check_completion()
	return 0

// Give 'em their reward for a job well done!
/datum/contract/proc/reward(var/mob/living/worker)
	var/datum/money_account/M
	for(var/datum/money_account/D in all_money_accounts)
		if(D.owner_name == worker.real_name)
			M = D

	if(!M)
		return

	/*
		Too easy to just check the source for key words and then monitor transaction logs
		var/company = "[pick(list("GreenGo", "Afterburn", "Feeform", "Mr. Pete", "Punko"))] [pick(list("Ltd.", "Corp.", "Inc.", "Conglomerate", "Lottery", "Funds"))]"
		var/purpose = "[pick(list("Investment returns", "Beneficiary transfer", "Freelance work completion"))]"
		var/terminal = "[pick(list("TrussCo.", "CashMonger", "Leeay"))] ME Terminal #[rand(111,444)]"
		charge_to_account(M.account_number, company, purpose, terminal, reward)
	*/
	M.money += reward
