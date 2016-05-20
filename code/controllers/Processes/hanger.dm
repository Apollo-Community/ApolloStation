/datum/controller/process/hanger_scheduler/setup()
	name = "hanger_scheduler"
	schedule_interval = 40 // every 4 seconds

	if(!hanger_scheduler)
		hanger_scheduler = new

/datum/controller/process/hanger_scheduler/doWork()
	hanger_scheduler.process()
