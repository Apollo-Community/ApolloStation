/datum/cell_auto_master
	var/group_age = 0 // The number of ticks since the group was created
	var/group_age_max = 25 // The maximum number of ticks the group is allowed to survive
	var/cell_type = null
	var/list/atom/movable/cell/cells = list()

/datum/cell_auto_master/New( var/loc as turf, size = 0 )
	..()

	if( loc && cell_type )
		PoolOrNew( cell_type, list( loc, src ))

	if( size )
		group_age_max = size

/datum/cell_auto_master/Destroy()
	for( var/cell in cells )
		qdel( cell )

	..()

/datum/cell_auto_master/proc/process()
	if( !cells.len )
		qdel( src )

	group_age++

	for( var/atom/movable/cell/cell in cells )
		cell.process()

/datum/cell_auto_master/proc/shouldProcess()
	if( group_age_max )
		if( group_age >= group_age_max )
			return 0

	return 1
