/datum/controller/process/cell_auto/setup()
	name = "cellular automata"
	schedule_interval = 2 // needs to be this low, internally it only processes each type as it needs it				//makesmesad ~stu
	cpu_threshold = 25

/datum/controller/process/cell_auto/doWork()
	cell_auto_manager.fire()

/datum/controller/process/cell_auto/getStatName()
	return ..()
