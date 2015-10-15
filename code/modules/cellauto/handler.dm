/datum/cell_auto_handler
	var/list/datum/cell_auto_master/masters = list()

/datum/cell_auto_handler/New()
	..()

/datum/cell_auto_handler/proc/process()
	for( var/datum/cell_auto_master/master in masters )
		master.process()
