/datum/cell_auto_handler
	var/tick_interval = 10
	var/list/datum/cell_auto_master/masters = list()

/datum/cell_auto_handler/New(var/interval = 0)
	if( interval )
		tick_interval = interval

	..()

/datum/cell_auto_handler/proc/process()
	for( var/datum/cell_auto_master/master in masters )
		master.process()
