/datum/controller/process/mob
	var/tmp/datum/updateQueue/updateQueueInstance

/datum/controller/process/mob/setup()
	name = "mob"
	schedule_interval = 40 // every 2 seconds
	cpu_threshold = 50
	updateQueueInstance = new

/datum/controller/process/mob/started()
	..()
	if(!updateQueueInstance)
		if(!mob_list)
			mob_list = list()
		else if(mob_list.len)
			updateQueueInstance = new

/datum/controller/process/mob/doWork()
	if(updateQueueInstance)
		updateQueueInstance.init(mob_list, "Life")
		updateQueueInstance.Run()

/datum/controller/process/mob/getStatName()
	return ..()+"([mob_list.len])"
