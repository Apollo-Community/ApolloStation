/datum/controller/process/cell_auto/setup()
	name = "cellular automata"
	schedule_interval = 2
	testing( "Cellular automata process setup complete" )

/datum/controller/process/cell_auto/doWork()
	cell_auto_manager.fire()

/datum/controller/process/cell_auto/getStatName()

