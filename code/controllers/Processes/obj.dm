var/global/list/object_profiling = list()
/var/global/datum/controller/process/obj/ObjProcess

/datum/controller/process/obj/setup()
    name = "obj"
    schedule_interval = 40 // every 4 seconds
    cpu_threshold = 50

    ObjProcess = src

/datum/controller/process/obj/doWork()
    for(var/obj/O in processing_objects)
        if(O)
            O.process()
            continue
        processing_objects.Remove(O)
        scheck()

/datum/controller/process/obj/getStatName()
    return ..()+"([processing_objects.len])"
