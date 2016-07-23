/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

	New()
		..()

		name = initial( name )

/turf/simulated/floor/airless/landing_pad
	icon = 'icons/turf/special/landingpad.dmi'

/turf/simulated/floor/airless/hull
	icon_state = "hull"
	desc = "There's probably something under this."

	temperature = T20C-270

	New()
		..()
		name = "hull"

/turf/simulated/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_type = /obj/item/stack/tile/light

	New()
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n

/turf/simulated/floor/light/rainbow
	name = "Dance floor"
	light_range = 5
	icon_state = "light_on-c"
	floor_type = /obj/item/stack/tile/light


/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_type = /obj/item/stack/tile/wood

/turf/simulated/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	intact = 0

/turf/simulated/floor/engine/make_plating()
	return

/turf/simulated/floor/engine/nitrogen
	oxygen = 0

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class='notice'>Removing rods...</span>"
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor)
			var/turf/simulated/floor/F = src
			F.make_plating()
			return

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/shuttle_beacon_floor
	name = "Floor plating with intergratged shuttle beacon"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"

/turf/simulated/floor/engine/n20
	New()
		. = ..()
		assume_gas("sleeping_agent", 2000)

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/bspace_safe
	name = "phoron-reinforced floor"
	icon_state = "bproof"
	thermal_conductivity = 0.025
	heat_capacity = 500000
	intact = 0

	New()
		. = ..()

/turf/simulated/floor/freezer
	icon_state = "showroomfloor"
	temperature = T20C-20

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_type = null
	intact = 0

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/airless/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	name = "space"
	plane = SPACE_PARALLAX_PLANE - 1

	temperature = T20C-270

	New()
		..()
		//icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
		name = "space"

	ex_act(severtiy)
		if(1.0)
			var/area/A = get_area( src )
			var/base_turf = A.base_turf

			src.ChangeTurf( base_turf )
		return

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	light_range = 1
	light_color = "#269CDF"
	light_power = 1
	light_range = 2

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"
	light_range = 1
	light_color = "#059100"
	light_power = 1
	light_range = 2

/turf/simulated/floor/dock_one
	icon = 'icons/turf/floors.dmi'
	icon_state = "One"
	light_range = 1

/turf/simulated/floor/dock_two
	icon = 'icons/turf/floors.dmi'
	icon_state = "Two"
	light_range = 1

/turf/simulated/floor/dock_tree
	icon = 'icons/turf/floors.dmi'
	icon_state = "Tree"
	light_range = 1

/turf/simulated/floor/dock_Five
	icon = 'icons/turf/floors.dmi'
	icon_state = "Five"
	light_range = 1

/turf/simulated/floor/dock_tile
	icon = 'icons/turf/floors.dmi'
	icon_state = "Dock"
	light_range = 1

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/wall/ex_act(severity)
	var/area/A = get_area( src )
	var/base_turf = A.base_turf

	switch(severity)
		if(1.0)
			src.ChangeTurf(base_turf)
			statistics.increase_stat("damage_cost", rand( 4000, 5000 ))
			return
		if(2.0)
			src.ChangeTurf(/turf/simulated/shuttle/plating)
			if(prob(33)) new /obj/item/stack/sheet/metal(src)
		else
	return

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor/ex_act(severity)
	//set src in oview(1)
	var/area/A = get_area( src )
	var/base_turf = A.base_turf

	switch(severity)
		if(1.0)
			src.ChangeTurf(base_turf)
			statistics.increase_stat("damage_cost", rand( 1900, 2100 ))
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
					statistics.increase_stat("damage_cost", rand( 1900, 2000 ))
				if(2)
					src.ChangeTurf(base_turf)
					statistics.increase_stat("damage_cost", rand( 1900, 2100 ))
				if(3)
					src.ChangeTurf(/turf/simulated/shuttle/plating)
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/plating/vox	//Vox skipjack plating
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/vox	//Vox skipjack floors
	name = "skipjack floor"
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/simulated/floor/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"

/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

	New()
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				update_neighbors()

/turf/simulated/floor/grass/proc/update_neighbors()
	for(var/direction in cardinal)
		if(istype(get_step(src,direction),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,direction)
			FF.update_icon() //so siding get updated properly

/turf/simulated/floor/grass/make_plating()
	update_neighbors()

	..()

/turf/simulated/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_type = /obj/item/stack/tile/carpet

	New()
		if(!icon_state)
			icon_state = "carpet"
		..()
		update_neighbors()

/turf/simulated/floor/carpet/proc/update_neighbors()
	spawn(5)
		if(src)
			for(var/direction in list(1,2,4,8,5,6,9,10))
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet/make_plating()
	update_neighbors()

	..()


/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

/turf/simulated/floor/plating/lava
	name = "lava"
	icon = 'icons/turf/floors.dmi'
	icon_state = "lava"

	Entered(atom/A, atom/OL)
		..()

		visible_message( "\The [A] falls into the lava, melting beneath the molten surface!" )

		qdel(A)

/turf/simulated/floor/airless/trash
	name = "compacted trash"