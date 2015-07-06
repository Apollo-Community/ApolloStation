//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.
//I should really make the shuttle wall check run every time it's moved, but centcom uses unsimulated floors so !effort

var/list/blend_objects = list( /obj/structure/falsewall, /obj/structure/falserwall, /obj/machinery/door, /obj/structure/grille, /obj/structure/window ) // Objects which the walls blend with
var/list/noblend_objects = list( /obj/machinery/door/blast, /obj/machinery/door/firedoor, /obj/machinery/door/window )

/atom/proc/relativewall() //atom because it should be useable both for walls and false walls
	if(istype(src,/turf/simulated/floor/vault)||istype(src,/turf/simulated/wall/vault)) //HACK!!!
		return

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls
	//var/altbottom = 0
	if(!istype(src,/turf/simulated/shuttle/wall)) //or else we'd have wacky shuttle merging with walls action
		for( var/direction in cardinal )
			var/turf/T = get_step( src,direction )
			var/success = 0

			if( istype( T, /turf/simulated/wall ) )
				success = 1
			else
				for( var/atom/O in T ) // for each object in the turf
					for( var/b_type in blend_objects )
						if( istype( O, b_type ) && direction == SOUTH)
							//altbottom = 1
							success = 1
							for( var/n_type in noblend_objects )
								if( istype( O, n_type ) && direction == SOUTH)
									//altbottom = 0
									success = 0
						if( success )
							break
					if( success )
						break

			if( success )
				junction |= get_dir( src, T )

	/* This isn't very friendly with the rest of the code. Might eventually do something about it though.
	var/turf/T = get_step( src, SOUTH)
	if(altbottom && istype(src,/turf/simulated/wall))
		var/turf/simulated/wall/wall = src
		T.overlays += "[wall.walltype]bot[junction&EAST ? 1:0][junction&WEST ? 1:0]"
	else
		T.overlays.Cut()
	*/

	if(istype(src,/turf/simulated/wall))
		var/turf/simulated/wall/wall = src
		//if(altbottom)
		//	wall.icon_state = "[wall.walltype][junction]b"
		//else
		wall.icon_state = "[wall.walltype][junction]"
	else if (istype(src,/obj/structure/falserwall) )
		src.icon_state = "rwall[junction]"
	else if (istype(src,/obj/structure/falsewall))
		var/obj/structure/falsewall/fwall = src
		fwall.icon_state = "[fwall.mineral][junction]"

	return

/atom/proc/relativewall_neighbours()
	for(var/turf/simulated/wall/W in range(src,1))
		W.relativewall()
	for(var/obj/structure/falsewall/W in range(src,1))
		W.relativewall()
		W.update_icon()//Refreshes the wall to make sure the icons don't desync
	for(var/obj/structure/falserwall/W in range(src,1))
		W.relativewall()
	return

/turf/simulated/wall/New()
	relativewall_neighbours()
	..()

/*/turf/simulated/shuttle/wall/New()

	spawn(20) //testing if this will make /obj/machinery/shuttle and /door count - It does, it stays.
		if(src.icon_state in list("wall1", "wall", "diagonalWall", "wall_floor", "wall_space")) //so wizard den, syndie shuttle etc will remain black
			for(var/turf/simulated/shuttle/wall/W in range(src,1))
				W.relativewall()

	..()*/

/turf/simulated/wall/Del()
	spawn(rand(1,10))
		for(var/turf/simulated/wall/W in range(src,1))
			W.relativewall()

		for(var/obj/structure/falsewall/W in range(src,1))
			W.relativewall()

		for(var/obj/structure/window/W in range(src, 1))
			W.update_icon()

	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0
		for(var/obj/effect/supermatter_crystal/crystal in get_step(src,direction))
			if(!crystal.floor) //crystals drop to the floor
				crystal.floor = 1
				crystal.icon_state = "supermatter_crystalf"
				crystal.pixel_x = 0
				crystal.pixel_y = 0

	..()

/*
/turf/simulated/wall/relativewall()
	if(istype(src,/turf/simulated/wall/vault)) //HACK!!!
		return

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)//Only 'like' walls connect -Sieve
				junction |= get_dir(src,W)
	for(var/obj/structure/falsewall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)
				junction |= get_dir(src,W)
	for(var/obj/structure/falserwall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)
				junction |= get_dir(src,W)
	var/turf/simulated/wall/wall = src


	return
*/