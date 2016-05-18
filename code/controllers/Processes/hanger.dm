/datum/controller/process/hanger_schedular/setup()
	name = "hanger_schedular"
	schedule_interval = 40 // every 4 seconds

	if(!hanger_schedular)
		hanger_schedular = new

/datum/controller/process/hanger_schedular/doWork()
	hanger_schedular.process()
