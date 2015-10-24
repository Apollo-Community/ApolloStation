/datum/controller/process/disease
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/disease/setup()
	name = "disease"
	schedule_interval = 30 // every 3 seconds
	cpu_threshold = 20
	updateQueueInstance = new

/datum/controller/process/disease/doWork()
	updateQueueInstance.init(active_diseases, "process")
	updateQueueInstance.Run()

/datum/controller/process/disease/getStatName()
	return ..()+"([active_diseases.len])"
