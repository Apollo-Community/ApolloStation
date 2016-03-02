/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take datum/contracts, and are rewarded for successful completion. 
*/

/datum/antagonist
	var/name = "Antagonist"
	var/gamemode = "" // The gamemode associated with this antagonist
	var/datum/contract/list/active_contracts = list() // Currently active contracts for the antagonist

	var/datum/contract/list/completed_contracts = list()
	var/mob/living/antag = null

/datum/antagonist/New()
	..()
	
/datum/antagonist/proc/contract_start(var/datum/contract/contract)
	active_contracts += contract

/datum/antagonist/proc/contract_ended(var/datum/contract/contract, var/success = 0)
	active_contracts -= contract
	if(success)
		completed_contracts += contract