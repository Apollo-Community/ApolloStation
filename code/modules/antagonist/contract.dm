/datum/contract
	var/title = "Ordinary Contract" // Contract name/title
	var/desc = "Complete the contract" // Contract information, what is required to complete it?
	var/time_limit = 3600 // How long you have to complete the contract after accepting it (in seconds)

	var/mob/living/worker = null

	var/finished = 0
	var/completed = 0
	var/contract_start = 0
	var/time_elapsed = 0

/datum/contract/New()
	..()
	
	time_limit *= 10

// Start the contract!
/datum/contract/proc/start()
	contract_start = world.time

	contract_ticker.contracts += src

// End the contract
/datum/contract/proc/end(var/success = 0)
	time_elapsed = world.time - contract_start
	finished = 1
	completed = success

	worker.antagonist.completed_contract(src)

	if(success)
		reward()

// Give 'em their reward for a job well done!
/datum/contract/proc/reward()
	return

// Check if the contract is completed.
/datum/contract/proc/check_completion()
	return 0