var/global/datum/uplink/uplink

var/global/datum/contract/list/regular_contracts = list()
var/global/datum/contract/list/restricted_contracts = list()

/datum/uplink
	var/datum/contract/list/contracts = list() // All available contracts on the uplink
	var/datum/contract/list/contracts_completed = list()

	var/contracts_min = 5 // Minimum amount of contracts that will appear
	var/contracts_max = 10 // Maximum amount of contracts that will appear
	var/restricted_contracts_min = 2 // Minimum amount of contracts with a notoriety requirement that will appear
	var/restricted_contracts_max = 4 // Minimum amount of contracts with a notoriety requirement that will appear

/datum/uplink/New()
	..()

	var/datum/contract/list/all_contracts = typesof(/datum/contract)
	for(var/datum/contract/C in all_contracts)
		if(C.min_notoriety > 0)
			restricted_contracts += C
		else
			regular_contracts += C

	// Sanity. There should always be regular contracts
	if(regular_contracts.len == 0)	return

	var/path = pick(regular_contracts)
	for(var/i = 0; i < rand(contracts_min, contracts_max); i++)
		contracts += new path()

	if(restricted_contracts.len == 0)	return

	path = pick(restricted_contracts)
	for(var/i = 0; i < rand(restricted_contracts_min, restricted_contracts_max); i++)
		contracts += new path()

/datum/uplink/proc/update_contracts()
	if(contracts.len == (contracts_max + restricted_contracts_max))
		return

	var/regular_contracts
	for(var/datum/contract/C in contracts)
		if(C.min_notoriety == 0)
			regular_contracts++
	var/restricted_contracts = contracts.len - regular_contracts

	var/path = pick(regular_contracts)
	if(regular_contracts < contracts_min)
		for(var/i = 0; i < rand(1, contracts_max - regular_contracts); i++)
			contracts += new path()

	path = pick(restricted_contracts)
	if(restricted_contracts < restricted_contracts_min)
		for(var/i = 0; i < rand(1, restricted_contracts_max - restricted_contracts); i++)
			contracts += new path()

/datum/uplink/proc/contract_ended(var/datum/contract/C)
	contracts -= C
	contracts_completed += C

	update_contracts()