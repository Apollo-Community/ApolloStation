var/global/list/turf/processing_turfs = list()

/datum/controller/process/turf/setup()
	name = "turf"
	schedule_interval = 40 // every 4 seconds

/datum/controller/process/turf/doWork()
	for(var/turf/T in processing_turfs)
		if(T.process() == PROCESS_KILL)
			processing_turfs.Remove(T)

/datum/controller/process/turf/getContext()
	return ..()+"(TURF:[processing_turfs.len])"
