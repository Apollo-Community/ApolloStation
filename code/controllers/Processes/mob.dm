/var/global/datum/controller/process/mob/MobProcess

/datum/controller/process/mob/setup()
    name = "mob"
    schedule_interval = 20 // every 2 seconds
    cpu_threshold = 50

    MobProcess = src

/datum/controller/process/mob/doWork()
    for(var/mob/M in mob_list)
        if(M)
            M.Life()
            continue
        mob_list.Remove(M)
        scheck()

/datum/controller/process/mob/getStatName()
    return ..()+"([mob_list.len])"
