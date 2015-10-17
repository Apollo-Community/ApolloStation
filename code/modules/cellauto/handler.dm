/datum/cell_auto_handler
	var/list/datum/cell_auto_master/masters = list()
	var/last_tick = 0
	var/delay = 10 // One second

/datum/cell_auto_handler/New(var/interval = 0)
	..()

	last_tick = world.timeofday

	if( interval )
		delay = interval

/datum/cell_auto_handler/proc/process()
	last_tick = world.timeofday

	for( var/datum/cell_auto_master/master in masters )
		master.process()

	return

/datum/cell_auto_handler/proc/shouldProcess()
	if((( world.timeofday - last_tick) > delay ) || (( world.timeofday - last_tick ) < 0))
		return 1

	return 0