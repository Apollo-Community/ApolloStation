/datum/controller/process/event/setup()
	name = "event controller"
	schedule_interval = 40 // every 2 seconds
	cpu_threshold = 50

/datum/controller/process/event/doWork()
	event_manager.process()
