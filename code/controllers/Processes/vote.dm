/datum/controller/process/vote/setup()
	name = "vote"
	schedule_interval = 50 // every 5 seconds

/datum/controller/process/vote/doWork()
	vote.process()
