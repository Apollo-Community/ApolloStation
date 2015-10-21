/datum/controller/process/cell_auto/setup()
	name = "cellular automata"
	schedule_interval = 30
	cpu_threshold = 25

/datum/controller/process/cell_auto/doWork()
	cell_auto_manager.fire()

/datum/controller/process/cell_auto/getStatName()
	return ..()
