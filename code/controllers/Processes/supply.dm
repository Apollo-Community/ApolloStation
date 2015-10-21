/datum/controller/process/supply/setup()
	name = "supply controller"
	schedule_interval = 300 // every 30 seconds
	cpu_threshold = 20

/datum/controller/process/supply/doWork()
	supply_controller.process()
