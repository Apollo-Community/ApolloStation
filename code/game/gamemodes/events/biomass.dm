// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/effect/biomass
	name = "biomass"
	desc = "Space barf from another dimension. It just keeps spreading!"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "stage1"
	anchored = 1
	density = 0
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/biomass_controller/master = null

	New()
		return

	Destroy()
		if(master)
			master.vines -= src
			master.growth_queue -= src
		..()

/obj/effect/biomass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!W || !user || !W.type) return
	switch(W.type)
		if(/obj/item/weapon/circular_saw) die()
		if(/obj/item/weapon/kitchen/utensil/knife) die()
		if(/obj/item/weapon/scalpel) die()
		if(/obj/item/weapon/twohanded/fireaxe) die()
		if(/obj/item/weapon/hatchet) die()
		if(/obj/item/weapon/melee/energy) die()
		if(/obj/item/weapon/melee/energy/sword) die()
		if(/obj/item/weapon/pickaxe/plasmacutter) die()
		if(/obj/item/weapon/scythe) die()

		//less effective weapons
		if(/obj/item/weapon/wirecutters)
			if(prob(50)) die()
		if(/obj/item/weapon/shard)
			if(prob(25)) die()

		if(/obj/item/weapon/weldingtool)
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(5, user)) die()
		else
			user << "[W] not sharp or hot enough to cut trough the biomass."
	..()

/obj/effect/biomass_controller
	var/list/obj/effect/biomass/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	var/gas_type = "oxygen"
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the biomasssss..s' size to something less than 20 plots, it won't grow anymore.

	New()
		if(!istype(src.loc,/turf/simulated/floor))
			qdel(src)
		gas_type = pick("oxygen","nitrogen","carbon_dioxide","phoron","sleeping_agent")
		spawn_biomass_piece(src.loc)
		processing_objects.Add(src)

	Destroy()
		processing_objects.Remove(src)
		..()

	proc/spawn_biomass_piece(var/turf/location)
		var/obj/effect/biomass/BM = new(location)
		growth_queue += BM
		vines += BM
		BM.master = src

	process()
		if(!vines)
			qdel(src) //space  vines exterminated. Remove the controller
			return
		if(!growth_queue)
			qdel(src) //Sanity check
			return
		if(vines.len >= 250 && !reached_collapse_size)
			reached_collapse_size = 1
		if(vines.len >= 30 && !reached_slowdown_size )
			reached_slowdown_size = 1

		var/maxgrowth = 0
		if(reached_collapse_size)
			maxgrowth = 0
		else if(reached_slowdown_size)
			if(prob(25))
				maxgrowth = 1
			else
				maxgrowth = 0
		else
			maxgrowth = 4
		var/length = min( 30 , vines.len / 5 )
		var/i = 0
		var/growth = 0
		var/list/obj/effect/biomass/queue_end = list()

		for( var/obj/effect/biomass/BM in growth_queue )
			i++
			queue_end += BM
			growth_queue -= BM
			if(BM.energy < 2) //If tile isn't fully grown
				if(prob(20))
					BM.grow()

			if(BM.spread())
				growth++
				if(growth >= maxgrowth)
					break
			if(i >= length)
				break

		growth_queue = growth_queue + queue_end

/obj/effect/biomass/proc/grow()
	if(!energy)
		src.icon_state = "stage2"
		energy = 1
		src.opacity = 0
		src.density = 0
		layer = 5
	else
		src.icon_state = "stage3"
		src.opacity = 0
		src.density = 1
		energy = 2

/obj/effect/biomass/proc/spread()
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	if(istype(step,/turf/simulated/floor))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/effect/biomass,F))
			if(F.Enter(src))
				if(master)
					master.spawn_biomass_piece( F )
					return 1
	return 0

/obj/effect/biomass/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(90))
				die()
				return
		if(3.0)
			if (prob(50))
				die()
				return
	return

/obj/effect/biomass/fire_act(null, temp, volume) //hotspots kill biomass
	die()

//To handle death of biomass
/obj/effect/biomass/proc/die()
	//Reliese some gas if its fullgrown and with a prop of 50 percent.
	if(energy == 2 && prob(50))
		src.visible_message("[src] emits an audible pop as someting rupteres and gas is released.", "You hear an audible pop.")
		var/datum/gas_mixture/air_contents = new
		air_contents.volume = 5
		air_contents.temperature = T20C
		air_contents.adjust_gas(master.gas_type, 5)	//Not much but enough to cause harm if not noticed.
		pump_gas(src, air_contents, src.loc.return_air(), air_contents.total_moles)
	src.visible_message("[src] shrivels up lifeless and crumbles into flakes.", "")
	qdel(src)

/proc/biomass_infestation()

	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(F.contents.len < 2) //one shot is occupied by the lighting overlay.
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			new/obj/effect/biomass_controller(T) //spawn a controller at turf
			message_admins("<span class='notice'>Biomass spawned at [T.loc.loc] ([T.x],[T.y],[T.z])", "EVENT:</span>")
