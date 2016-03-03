// The ticker doesn't turn in your contracts for you, but it does fail them if you die, lose antag, time runs out, etc.

var/global/datum/controller/process/contractticker/contract_ticker

/datum/controller/process/contractticker
	var/datum/contract/list/contracts // Currently active contracts
	var/next_contract_update

/datum/controller/process/contractticker/setup()
	name = "contract ticker"
	schedule_interval = 10 // Every second, so we don't let contracts run past their time limit

	contracts = list()

/datum/controller/process/contractticker/doWork()
	if(contracts.len == 0)	return

	for(var/datum/contract/C in contracts)
		if(world.time >= C.contract_start + C.time_limit)
			C.end()
			continue

		C.check_completion()