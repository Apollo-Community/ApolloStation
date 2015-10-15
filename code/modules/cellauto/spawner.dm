/obj/cell_spawner
	var/spawn_type = null

/obj/cell_spawner/New()
	..()

	if( spawn_type )
		new spawn_type( get_turf( src ))

	qdel( src )

/obj/cell_spawner/v_wave
	spawn_type = /atom/movable/cell/v_wave