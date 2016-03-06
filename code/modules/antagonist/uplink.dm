var/global/datum/uplink/uplink

var/global/list/regular_contracts = list()
var/global/list/restricted_contracts = list()

/datum/uplink
	var/datum/contract/list/contracts = list() // All available contracts on the uplink
	var/datum/contract/list/contracts_completed = list()

	var/contracts_min = 5 // Minimum amount of contracts that will appear
	var/contracts_max = 10 // Maximum amount of contracts that will appear
	var/restricted_contracts_min = 2 // Minimum amount of contracts with a notoriety requirement that will appear
	var/restricted_contracts_max = 4 // Minimum amount of contracts with a notoriety requirement that will appear

/datum/uplink/New()
	..()

	if(uplink)
		qdel(uplink)
	uplink = src

	for(var/path in subtypes(/datum/contract))
		var/datum/contract/C = new path()
		if(C.min_notoriety > 0)
			restricted_contracts += path
		else
			regular_contracts += path
		qdel(C)

	//update_contracts() this is done when the game starts

/datum/uplink/proc/update_contracts()
	if(contracts.len == (contracts_max + restricted_contracts_max))
		return

	var/amt_regular_contracts
	for(var/datum/contract/C in contracts)
		if(C.min_notoriety == 0)
			amt_regular_contracts++
	var/amt_restricted_contracts = contracts.len - amt_regular_contracts

	if(regular_contracts.len == 0)	return

	// Fill up to the minimum + some more
	var/path = pick(regular_contracts)
	var/goal = contracts_min + rand(0, contracts_max - amt_regular_contracts)
	var/safety = contracts_max // You'll never add more than this anyways
	while(amt_regular_contracts < goal && safety > 0)
		safety--
		contracts += new path()
		path = pick(regular_contracts)
		amt_regular_contracts++

	if(restricted_contracts.len == 0)	return

	path = pick(restricted_contracts)
	goal = contracts_min + rand(0, restricted_contracts_max - amt_restricted_contracts)
	safety = restricted_contracts_max
	while(amt_regular_contracts < goal && safety > 0)
		safety--
		contracts += new path()
		path = pick(restricted_contracts)
		amt_restricted_contracts++

/datum/uplink/proc/contract_ended(var/datum/contract/C)
	contracts -= C
	contracts_completed += C

	update_contracts()

// gets contracts (of a type)
/datum/uplink/proc/get_contracts(var/type)
	if(!type)
		return contracts

	var/datum/contract/list/contracts_of_type = list()
	for(var/datum/contract/C in contracts)
		if(istype(C, type))
			contracts_of_type += C
	return contracts_of_type
