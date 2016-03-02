/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take datum/contracts, and are rewarded for successful completion. 
*/

/datum/antagonist
	var/name = "Antagonist"
	var/gamemode = "" // The gamemode associated with this antagonist
	var/datum/contract/list/contracts = list() // Type paths for all contracts associated with this antagonist
	var/datum/contract/list/active_contracts = list() // Currently active contracts for the antagonist

	var/datum/contract/list/completed_contracts = list()
	var/commendations = 0

/datum/antagonist/New()
	..()
	
	contracts = typesof(/datum/contract)
	var/datum/contract/C = pick(contracts)
	active_contracts += C
	C.start()

/datum/antagonist/proc/completed_contract(var/datum/contract/contract)
	active_contracts -= contract
	completed_contracts += contract