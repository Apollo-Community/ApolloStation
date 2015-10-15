/datum/cell_auto_handler
	var/list/cells = list()

/datum/cell_auto_handler/New()
	..()

/datum/cell_auto_handler/proc/process()
	for( var/atom/movable/cell/cell in cells )
		cell.process()
