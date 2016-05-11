var/global/list/object_profiling = list()
/var/global/datum/controller/process/obj/ObjProcess

/datum/controller/process/obj/setup()
    name = "obj"
    schedule_interval = 40 // every 4 seconds
    ObjProcess = src

/datum/controller/process/obj/doWork()
	var/c = 0
	for(var/obj/O in processing_objects)
		if(!O.gcDestroyed)
			O.process()
			if(!(c++ % 20))		scheck()
		else
			processing_objects.Remove(O)

/datum/controller/process/obj/getContext()
    return ..()+"(OBJ:[processing_objects.len])"
