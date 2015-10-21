/datum/controller/process/sun/setup()
	name = "sun"
	schedule_interval = 40 // every second
	cpu_threshold = 40
	sun = new

/datum/controller/process/sun/doWork()
	sun.calc_position()
