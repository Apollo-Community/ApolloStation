/datum/contract
	var/title = "Ordinary Contract" // Contract name/title
	var/desc = "Complete the contract" // Contract information, what is required to complete it?
	var/time_limit = 3600 // How long before the contract expires after it's put on the uplink (in seconds)
	var/min_notoriety = 0 // The minimum amount of notoriety you need to take on the contract
	var/rarity = 100 // prob(rarity) is used when determining if the contract should appear on the Uplink
	var/reward = 1000 // Thaler reward

	var/mob/living/list/workers = null

	var/finished = 0
	var/completed = 0
	var/contract_start = 0
	var/time_elapsed = 0

/datum/contract/New()
	..()
	
	workers = list()

	time_limit *= 10
	contract_start = world.time
	if(contract_ticker)
		contract_ticker.contracts += src

// set title, desc, etc. here
/datum/contract/proc/set_details()
	return

/datum/contract/proc/can_accept(var/mob/living/M)
	if(!M.mind.antagonist)	return 0
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
		if(M != worker)
			worker << "<font color=red>A contract you signed up for has ended. The reward was not paid out to you.</font>\n<B>[src.title]</B>\n<I>[src.desc]</I></font>"
			M.mind.antagonist.contract_ended(src, 0)
		else
			// v is PLACEHOLDER!!! You'll have to check your uplink later on to see if you completed it.
			worker << "<font color=green>You've completed a contract</font>\n<B>[src.title]</B>\n<I>[src.desc]</I></font>"
			worker.mind.antagonist.contract_ended(src, 1)
			reward(worker)

	contract_ticker.contracts -= src
	uplink.contract_ended(src)

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

/datum/contract/proc/formatted_time(var/time = time_limit)
	var/list/amounts = list()
	amounts["hrs"] = Floor((time/10)/3600)
	amounts["min"] = ((time/10)/60) % 60
	amounts["sec"] = (time/10) % 60
	var/time_string = ""
	if(amounts["hrs"] > 0)
		time_string += "[amounts["hrs"]] hour[amounts["hrs"] > 1 ? "s" : ""]"
	if(amounts["min"] > 0)
		time_string += "[amounts["sec"] > 0 && amounts["hrs"] ? ", " : (amounts["hrs"] > 0 ? " and " : "")][amounts["min"]] minute[amounts["min"] > 1 ? "s" : ""]"
	if(amounts["sec"] > 0)
		time_string += "[(amounts["hrs"] > 0 || amounts["min"] > 0) ? " and " : ""][amounts["sec"]] second[amounts["sec"] > 1 ? "s" : ""]"

	return time_string