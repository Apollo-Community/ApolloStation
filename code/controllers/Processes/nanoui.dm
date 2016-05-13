/datum/controller/process/nanoui

/datum/controller/process/nanoui/setup()
	name = "nanoui"
	schedule_interval = 20 // every 2 second

/datum/controller/process/nanoui/doWork()
	for(var/datum/nanoui/N in nanomanager.processing_uis)
		if(!N.gcDestroyed)
			N.process()
			continue
		nanomanager.processing_uis.Remove()

/datum/controller/process/nanoui/getContext()
	return ..()+" - (UIs:[nanomanager.processing_uis.len])"
