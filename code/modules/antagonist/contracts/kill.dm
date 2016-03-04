/datum/contract/kill
	title = "Kill the Target"
	desc = "We're looking to send a message. A rather strong one."
	time_limit = 2700

	var/reward = 3000
	var/mob/living/target = null

/datum/contract/kill/New()
	..()

	for(var/mob/living/M in living_mob_list)
		if(M.client)
			target = M
			break

	if(!target)
		// Let the uplink see if it's a notoriety-restricted contract before we delete ourselves
		if(ticker.current_state != 1)
			qdel(src)
		return

	title = "[pick(list("Kill", "Murder", "Eliminate"))] [target.real_name]"
	desc = "[target.real_name] [pick(list("would serve us better dead", "has been causing us trouble recently", "has badmouthed the wrong people"))]. [pick(list("Kill them at your earliest convenience", "Ensure that they don't live another day", "Eliminate them"))]." 

/datum/contract/kill/check_completion()
	if(target && (target.stat & DEAD))
		if(target.lastattacker && (target.lastattacker in workers))
			end(1, target.lastattacker)
			return
		// Fail! Someone who hasn't taken the contract killed them (probably themselves).
		end(0)
	else
		return

/datum/contract/kill/reward(var/mob/living/worker)
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

/datum/contract/kill/proc/get_taken_targets()
	var/datum/mind/list/taken = list()
	for(var/datum/contract/kill/C in uplink.contracts)
		if(istype(C) && C.target)	taken += C.target
	return taken

// Heads only
/datum/contract/kill/head
	title = "Assassinate Head of Staff"
	desc = "We're looking to instate one of our own agents in a position higher up. That means someone already there has to go."
	time_limit = 1200
	min_notoriety = 2

	reward = 6000

/datum/contract/kill/head/New()
	..()

	if(!(target.assigned_role in command_positions))
		var/datum/mind/list/taken = get_taken_targets()
		var/datum/mind/list/candidates = list()
		for(var/datum/mind/M in ticker.minds)
			if(!(M in taken) && ishuman(M.current) && M.current.stat != 2 && M.assigned_role in command_positions)
				candidates += M
		target = pick(candidates)

	if(!target)
		if(ticker.current_state != 1)
			qdel(src)
		return

	set_details()