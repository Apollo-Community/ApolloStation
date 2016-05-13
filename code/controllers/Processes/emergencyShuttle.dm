/datum/controller/process/emergencyShuttle/setup()
	name = "emergency shuttle"
	schedule_interval = 40 // every 4 seconds

	if(!emergency_shuttle)
		emergency_shuttle = new

/datum/controller/process/emergencyShuttle/doWork()
	emergency_shuttle.process()
