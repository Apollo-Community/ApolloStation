/datum/controller/process/vote/setup()
	name = "vote"
	schedule_interval = 50 // every 5 seconds
	cpu_threshold = 25

/datum/controller/process/vote/doWork()
	vote.process()
