var/global/datum/fusion_controller/fusion_controller = new()
/*
*	Regulates the fusion engine and this components.
*/
/datum/fusion_controller
	var/list/fusion_components = list()	//List of components making up the fusion reactor.
	var/mode = 1						//Mode, direct = 0, indirect = 1.
	var/gas = 0							//Is the gas release open.
	var/confield = 0
	var/conPower = 0					//Is the containment field active.
	var/list/plasma = list()			//List of plasma fields
	var/datum/gas_mixture/gas_contents = null	//Plasma must contain a mix of gasses.
	var/exchange_coef = 0.2
	var/beam_coef = 2
	var/decay_coef = 55000
	var/free_energy_coef = 0.5			//How the free energy from a fusion event is distributed (1 = all heat, 0 = all neutrons)
	var/heatpermability = 0				//Do we let the heat escape/exchange with the enviroment or do we contain it. (0 = contain, 0 = exchange)
	var/fusion_heat = 0
	var/gas_heat_coef = 1				//How gas effects the amount of heat generated from fusion
	var/gas_neutron_coef = 1			//How gas effects the amount of neutrons generated from fusion

/datum/fusion_controller/New()
	gas_contents = new /datum/gas_mixture()
	gas_contents.volume = 480
	gas_contents.temperature = T20C

/datum/fusion_controller/proc/process()
	if(fusion_components.len != 14)
		return
	pass_self()
	updatePlasma()
	calcFusion()
	calcDamage()
	calcConField()

/datum/fusion_controller/proc/pass_self()
	var/obj/machinery/power/fusion/core/core = fusion_components[13]
	core.controller = src

/datum/fusion_controller/proc/toggle_field()
	conPower = !conPower

/datum/fusion_controller/proc/toggle_gas()
	gas = !gas

/datum/fusion_controller/proc/toggle_permability()
	heatpermability = !heatpermability
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		p.toggle_heat_transfer()


//This spawns the "plasma" based upon the location of the core rod.
/datum/fusion_controller/proc/generatePlasma()
	var/obj/machinery/power/fusion/plasma/p
	var/obj/machinery/power/fusion/core/core = fusion_components[13]

	for(var/i in list(-2, 2))
		p = new(core.loc)
		p.x += i
		if(i == 2)
			p.dir = SOUTH
		if(i == -2)
			p.dir = NORTH
		plasma.Add(p)

	for(var/i in list(-2, 2))
		p = new(core.loc)
		p.y += i
		if(i == 2)
			p.dir = EAST
		if(i == -2)
			p.dir = WEST
		plasma.Add(p)

//Update the status of the plasma
/datum/fusion_controller/proc/updatePlasma()
	var/obj/machinery/power/fusion/core/core = fusion_components[13]
	if(plasma.len == 0 && gas)
		generatePlasma()

	pumpPlasma()

	if(plasma.len == 0 || isnull(gas_contents) || gas_contents.total_moles < 1)
		return

	if(!confield)
		leakPlasma()
		spawn(5)
			removePlasma()

	core.decay()

	//heat up plasma and temp sanity check
	var/heatdif = core.heat
	//The beams temerature is about 100k deg so we cap input there.
	if(gas_contents.temperature >= 1000000)
		heatdif = 0
	core.heat -= heatdif
	gas_contents.temperature += heatdif + fusion_heat - calcDecay(gas_contents.temperature)		//Calculating temp change
	if(gas_contents.temperature < 290)		//need to do a area check here
		gas_contents.temperature = 290
	gas_contents.update_values()
	fusion_heat = 0
	if(gas_contents.temperature > 100000000)
		gas_contents.temperature = 100000000
		gas_contents.update_values()

	if(gas_contents.temperature > 10000)
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.luminosity = min(gas_contents.temperature/7500, 2)
			p.set_light(3, p.luminosity, "##00D4FF")	//Light blue
			//p.icon_state = "plas_stream"
	else
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.icon_state = "plas_cool"


/datum/fusion_controller/proc/pumpPlasma()
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		pump_gas(r, r.get_tank_content(), gas_contents, r.get_tank_moles())

/datum/fusion_controller/proc/removePlasma()
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		spawn(5)
			qdel(p)
	plasma = list()

//If the containment field get disabled.. bad stuff.
//This can also be used to flood the room in case of an emerency so the reactor does not go boom.
/datum/fusion_controller/proc/leakPlasma()
	var/dif = gas_contents.temperature/4
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		pump_gas(p, gas_contents, p.loc.return_air(), gas_contents.total_moles/4)
		gas_contents.temperature -= dif

//Calculate plasma passive heat decal (will need to take in account gasses).
/datum/fusion_controller/proc/calcDecay(var/temp)
	return 2**(temp/(decay_coef))

//Containment field calculations and adjustment.. also sprite overlay.
/datum/fusion_controller/proc/calcConField()
	if(confield)
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.overlays = list(image(p.icon, "field_overlay"))
	else
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.overlays.Cut()

	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		if(conPower)
			//Power check here !
			r.battery = min(r.battery + 100, 5000)
		r.battery = max(r.battery - 25, 0)
		if(r.battery == 0)
			confield = 0

		else
			confield = 1

//When does fusion happen ?
/datum/fusion_controller/proc/calcFusion()
	if(plasma.len == 0 || isnull(gas_contents))
		return
	if(gas_contents.temperature < 90000)
		return
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		var/change = min(((gas_contents.temperature/350000)*100), 25)			//This needs tweaking also with gass mixtures
		change = change * min((gas_contents.total_moles/240), 1)				//If there is less then the required amount of gass.
		if(prob(change))
			spawn()
				fusionEvent(p)

//Fusion event, generates heat neutrons wich generate energy via collectors.
/datum/fusion_controller/proc/fusionEvent(obj/machinery/power/fusion/plasma/p)
	world << "Fusion event!"
	var/neutrons = 100							//Will depent on gas mixture
	var/heat = 1000							//Will depent on gas mixture
	var/free_energy = 1000
	heat += free_energy*free_energy_coef
	neutrons += free_energy*(1-free_energy_coef)
	p.transfer_energy(neutrons)
	fusion_heat += heat
	gas_contents.update_values()
	p.spark()
	spawn()
		new/obj/effect/effect/plasma_ball(get_turf(p))

//Check if all components are pressent (14 of them)
/datum/fusion_controller/proc/checkComponents()
	if(fusion_components.len == 14)
		return 1
	return 0

//Calculate if we should do damage to the rings according to heat of the gas.
//A random ring will take 1 point of damage for every 5000 deg above 1 mil deg.
/datum/fusion_controller/proc/calcDamage()
	if(gas_contents.temperature > 1000000)
		var/i = pick(list(1,2,3,4,5,6,7,8,9,10,11,12))
		var/obj/machinery/power/fusion/component = fusion_components[i]
		component.damage += (gas_contents.temperature - 1000000)/5000

//Check if any of the components are critically damaged, warn and or fail (boom).
/datum/fusion_controller/proc/damage_act()
	for(var/obj/machinery/power/fusion/component in fusion_components)
		if(component.damage > 500 && component.damage < 800)
			//warning

		else if(component.damage > 800 && component.damage < 950)
			//Critical warning

		else if(component.damage > 999)
			//critically fail
			gas = 0
			leakPlasma()
			spawn()
				removePlasma()
				explosion(get_turf(component), 2, 4, 10, 15)



//LONG LIVE SPAGETTI !
/datum/fusion_controller/proc/findComponents()
	.=0
	var/list/temp_list = list()
	var/obj/machinery/power/fusion/core/c = locate(/obj/machinery/power/fusion/core)
	if(isnull(c))
		return
	c.controller = src
	var/obj/machinery/power/fusion/mag_ring = null
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST))
		//Getting the corner ring
		mag_ring = null
		mag_ring = locate(/obj/machinery/power/fusion/ring_corner/, get_step(get_step(c, dir),dir))
		if(!(istype(mag_ring, /obj/machinery/power/fusion/ring_corner) ||!isnull(mag_ring)))
			return

		//Getting straight rings and check dir on corner, let the spagetti begin.
		if(dir == NORTHWEST)
			if(!mag_ring.dir == EAST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),NORTH))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == EAST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),WEST))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == SOUTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)

		if(dir == NORTHEAST)
			if(!mag_ring.dir == SOUTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),NORTH))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == WEST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),EAST))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == SOUTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)

		if(dir == SOUTHEAST)
			if(!mag_ring.dir == WEST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),SOUTH))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == WEST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),EAST))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == NORTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)

		if(dir == SOUTHWEST)
			if(!mag_ring.dir == NORTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),WEST))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == NORTH || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)
			mag_ring = null
			mag_ring = locate(/obj/machinery/power/fusion/ring/, get_step(get_step(c, dir),SOUTH))
			if(!(istype(mag_ring, /obj/machinery/power/fusion/ring) ||!isnull(mag_ring)))
				return
			if(!mag_ring.dir == EAST || !mag_ring.anchored == 1)
				return
			temp_list.Add(mag_ring)

	temp_list.Add(c)
	if(temp_list.len != 13)
		return
	fusion_components = temp_list
	return 1

/datum/fusion_controller/proc/addComp(var/obj/machinery/computer/fusion/comp)
	fusion_components.Add(comp)