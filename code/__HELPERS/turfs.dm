// Returns the atom sitting on the turf.
// For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
/proc/get_atom_on_turf(var/atom/movable/M)
	var/atom/mloc = M
	while(mloc && mloc.loc && !istype(mloc.loc, /turf/))
		mloc = mloc.loc
	return mloc

/proc/iswall(turf/T)
	return (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall) || istype(T, /turf/simulated/shuttle/wall))

/proc/isfloor(turf/T)
	return (istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle/floor))

/proc/get_distant_turf(atom/start, var/range, var/dir)
	var/turf/T = null

	switch(dir)
		if(NORTH)
			T = locate( start.x, start.y+range, start.z )
		if(NORTHEAST)
			T = locate( start.x+range, start.y+range, start.z )
		if(EAST)
			T = locate( start.x+range, start.y, start.z )
		if(SOUTHEAST)
			T = locate( start.x+range, start.y-range, start.z )
		if(SOUTH)
			T = locate( start.x, start.y-range, start.z )
		if(SOUTHWEST)
			T = locate( start.x-range, start.y-range, start.z )
		if(WEST)
			T = locate( start.x-range, start.y, start.z )
		if(NORTHWEST)
			T = locate( start.x-range, start.y+range, start.z )

	return T