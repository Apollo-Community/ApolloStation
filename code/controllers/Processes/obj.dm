var/global/list/object_profiling = list()
/datum/controller/process/obj
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/obj/setup()
	name = "obj"
	schedule_interval = 40 // every 4 seconds
	cpu_threshold = 50
	updateQueueInstance = new

/datum/controller/process/obj/started()
	..()
	if(!updateQueueInstance)
		if(!processing_objects)
			processing_objects = list()
		else if(processing_objects.len)
			updateQueueInstance = new

/datum/controller/process/obj/doWork()
	if(updateQueueInstance)
		updateQueueInstance.init(processing_objects, "process")
		updateQueueInstance.Run()

/datum/controller/process/obj/getStatName()
	return ..()+"([processing_objects.len])"
