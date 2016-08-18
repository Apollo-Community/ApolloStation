/datum/controller/process/fusion/setup()
	name = "fusion controller"
	schedule_interval = 2 // every 0.2 seconds

	if(!fusion_controller)
		fusion_controller = new

/datum/controller/process/fusion/doWork()
	fusion_controller.process()