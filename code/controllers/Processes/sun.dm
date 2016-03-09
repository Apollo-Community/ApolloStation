/datum/controller/process/sun/setup()
	name = "sun"
	schedule_interval = 40 // every second
	tick_allowance = 40
	sun = new

/datum/controller/process/sun/doWork()
	sun.calc_position()
