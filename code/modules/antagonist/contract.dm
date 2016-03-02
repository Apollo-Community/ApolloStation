/datum/contract
	var/title = "Ordinary Contract" // Contract name/title
	var/desc = "Complete the contract" // Contract information, what is required to complete it?
	var/time_limit = 3600 // How long before the contract expires after it's put on the uplink (in seconds)
	var/min_notoriety = 0 // The minimum amount of notoriety you need to take on the contract

	var/mob/living/list/workers = null

	var/finished = 0
	var/completed = 0
	var/contract_start = 0
	var/time_elapsed = 0

/datum/contract/New()
	..()
	
	time_limit *= 10
	contract_start = world.time
	contract_ticker.contracts += src

// Start the contract for a new antag
/datum/contract/proc/start(var/mob/living/worker)
	workers += worker
	worker.antagonist.contract_start()

// End the contract
/datum/contract/proc/end(var/success = 0, var/mob/living/worker)
	time_elapsed = world.time - contract_start
	finished = 1
	completed = success

	if(!success)
		for(var/mob/living/M in workers)
			M.antagonist.contract_ended(src, 0)
	else
		worker.antagonist.contract_ended(src, 1)
		reward(worker)

	uplink.contract_ended(src)

// Give 'em their reward for a job well done!
/datum/contract/proc/reward(var/mob/living/worker)
	return

// Check if the contract is completed.
/datum/contract/proc/check_completion()
	return 0