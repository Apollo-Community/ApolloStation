/datum/cell_auto_master
	var/group_age = 0 // The number of ticks since the group was created
	var/group_age_max = 25 // The maximum number of ticks the group is allowed to survive
	var/list/atom/movable/cell/cells = list()

/datum/cell_auto_master/New()
	..()

	testing( "New group of cells created" )

/datum/cell_auto_master/Destroy()
	for( var/cell in cells )
		qdel( cell )

	..()

/datum/cell_auto_master/proc/process()
	if( !shouldProcess() && !cells.len )
		qdel( src )

	group_age++

	for( var/atom/movable/cell/cell in cells )
		cell.process()

/datum/cell_auto_master/proc/shouldProcess()
	if( group_age >= group_age_max )
		return 0

	return 1