/datum/controller/process/mob/setup()
    name = "mob"
    schedule_interval = 20 // every 2 seconds

/datum/controller/process/mob/doWork()
	var/c = 0
	for(var/mob/M in mob_list)
		if(!M.gcDestroyed)
			M.Life()
			if(!(c++ % 20))		scheck()
		else
			mob_list.Remove(M)

/datum/controller/process/mob/getContext()
    return ..()+" - (MOB:[mob_list.len])"
