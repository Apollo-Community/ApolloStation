// This ticker controls contract completion

var/global/datum/controller/process/contractticker/contract_ticker

/datum/controller/process/contractticker
	var/datum/contract/list/contracts // Currently active contracts
	var/next_contract_update

/datum/controller/process/contractticker/setup()
	name = "contract ticker"
	schedule_interval = 50
	cpu_threshold = 50

	contracts = list()
	contract_ticker = src

/datum/controller/process/contractticker/doWork()
	if( contracts.len == 0 )	return

	for( var/datum/contract/C in contracts )
		if( C.time_limit && ( world.time >= ( C.contract_start + C.time_limit )))
			C.check_completion()
			if( !C.finished )
				C.end()
			continue

		C.check_completion()