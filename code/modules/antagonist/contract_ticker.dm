// The ticker doesn't turn in your contracts for you, but it does fail them if you die, lose antag, time runs out, etc.

var/global/datum/controller/process/contractticker/contract_ticker

/datum/controller/process/contractticker
	var/datum/contract/list/contracts // Currently active contracts

/datum/controller/process/contractticker/setup()
	name = "contract ticker"
	schedule_interval = 600 // Every 60 seconds

	contracts = list()

/datum/controller/process/contractticker/doWork()
	for(var/datum/contract/C in contracts)
		// End the contract immediately if they're not an antagonist anymore
		if(!C.worker.antagonist || C.worker.stat & DEAD)
			C.end()
			contracts -= C
			continue

		if(world.time >= C.contract_start + C.time_limit)
			C.end()