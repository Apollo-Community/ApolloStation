/datum/controller/process/disease

/datum/controller/process/disease/setup()
	name = "disease"
	schedule_interval = 30 // every 3 seconds
	tick_allowance = 20

/datum/controller/process/disease/doWork()
	for(var/datum/disease/D in active_diseases)
		if(D)
			D.process()
			continue
		active_diseases.Remove(D)

/datum/controller/process/disease/getStatName()
	return ..()+"([active_diseases.len])"
