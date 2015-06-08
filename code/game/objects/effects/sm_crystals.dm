//separate dm since hydro is getting bloated already

/obj/effect/supermatter_crystal
	name = "supermatter growth"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi'
	icon_state = "supermatter_crystalf_1"
	layer = 2.1
	l_color = "#8A8A00"
	var/smlevel = 0

	var/endurance = 100
	var/delay = 1200
	var/floor = 0
	var/spreadChance = 10
	var/spreadIntoAdjacentChance = 10
	var/lastTick = 0
	var/spreaded = 1
	var/deleted = 0

/obj/effect/supermatter_crystal/single
	spreadChance = 0

/obj/effect/supermatter_crystal/New(var/loc, var/level = 1)
	..()
	smlevel = level

	if (smlevel<2)
		l_color = "#808000"
		luminosity = 1
	else if (smlevel<3)
		l_color = "#C08000"
		luminosity = 2
	else if (smlevel<4)
		l_color = "#DF6000"
		luminosity = 2
	else if (smlevel<5)
		l_color = "#FF2000"
		luminosity = 1
	else if (smlevel<6)
		l_color = "#C00040"
		luminosity = 1
	else if (smlevel<7)
		l_color = "#800080"
		luminosity = 2
	else if (smlevel<8)
		l_color = "#4000C0"
		luminosity = 1
	else if (smlevel<9)
		l_color = "#008080"
		luminosity = 3
	else if (smlevel>=9)
		l_color = "#FFC0C0"
		luminosity = 4

	dir = CalcDir()

	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "supermatter_crystal"
	else
		if( prob( 10 )) // Only 10% of all floor crystals survive, so there's not a forest of 'em
			icon_state = "supermatter_crystalf"
			name = "supermatter crystal"
			density = 1
		else
			deleted = 1
			del( src )

	processing_objects += src

	SetLuminosity(3)
	lastTick = world.timeofday

/obj/effect/supermatter_crystal/Del()
	if( !deleted )
		if(smlevel>=5 && prob(smlevel*10))
			visible_message("\red <B>\The [src] explodes!</B>")
			supermatter_delamination(src, smlevel)
			return
		else
			visible_message("\red <B>\The [src] shatters!</B>")
			playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
			for(var/mob/living/l in range( src, 2 ))
				var/rads = 15*smlevel
				l.apply_effect(rads, IRRADIATE)
			new /obj/item/weapon/shard/supermatter( src.loc, max(1, smlevel-1) )

	processing_objects -= src
	..()

/obj/effect/supermatter_crystal/process()
	if(!spreaded)
		return
	if(smlevel == 0) // Hacky fix to get rid of divisions by zero, as well as depopulating crystals a bit.
		del(src)
	if(smlevel>=5 && prob(smlevel/50))
		del(src)


	if(((world.timeofday - lastTick) > delay) || ((world.timeofday - lastTick) < 0))
		lastTick = world.timeofday
		spreaded = 0

		for(var/mob/living/l in range( src, 2 ))
			var/rads = 5*smlevel
			l.apply_effect(rads, IRRADIATE)

		for(var/i=1,i<=3,i++)
			if(prob(spreadChance/smlevel))
				var/list/possibleLocs = list()
				var/spreadsIntoAdjacent = 0

				if(prob(spreadIntoAdjacentChance))
					spreadsIntoAdjacent = 1

				for(var/turf/simulated/floor/floor in view(3,src))
					if(spreadsIntoAdjacent || !locate(/obj/effect/supermatter_crystal) in view(1,floor))
						possibleLocs += floor

				if(!possibleLocs.len)
					break

				var/turf/newLoc = pick(possibleLocs)

				var/crystalCount = 0 //hacky
				var/placeCount = 1
				for(var/obj/effect/supermatter_crystal/shroom in newLoc)
					crystalCount++
				for(var/wallDir in cardinal)
					var/turf/isWall = get_step(newLoc,wallDir)
					if(isWall.density)
						placeCount++
				if(crystalCount >= placeCount)
					continue

				var/obj/effect/supermatter_crystal/child = new /obj/effect/supermatter_crystal(newLoc, max(1, smlevel-1))
				if( child )
					child.delay = delay
					child.endurance = endurance

				spreaded++

/obj/effect/supermatter_crystal/proc/CalcDir(turf/location = loc)
	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			return wallDir

/*
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/effect/supermatter_crystal/crystal in location)
		if(crystal == src)
			continue
		if(crystal.floor) //special
			direction &= ~16
		else
			direction &= ~crystal.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir
*/
	floor = 1
	return 1

/obj/effect/supermatter_crystal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	endurance -= W.force

	if (prob(min(smlevel*10, 50)))
		new /obj/item/weapon/shard/supermatter( src.loc, smlevel )

/obj/effect/supermatter_crystal/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/effect/supermatter_crystal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		endurance -= 5
		CheckEndurance()

/obj/effect/supermatter_crystal/proc/CheckEndurance()
	if(endurance <= 0)
		del(src)