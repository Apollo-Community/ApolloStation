/obj/cell_spawner/v_wave/New( loc as turf, var/size = 25, var/level = 1 )
	..()

	new /datum/cell_auto_master/v_wave( get_turf( src ), size, level )

	qdel( src )

/obj/cell_spawner/blotch/New()
	..()

	new /datum/cell_auto_master/blotch( get_turf( src ))

	qdel( src )