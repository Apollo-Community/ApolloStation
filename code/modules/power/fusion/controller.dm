/*
*	Regulates the fusion engine and this components.
*/
/datum/fusion_controller
	var/list/fusion_components = list()			//List of components making up the fusion reactor.
	var/mode = 1								//Mode, direct = 0, indirect = 1.
	var/gas = 0									//Is the gas release open.
	var/confield = 0
	var/conPower = 0							//Is the containment field active.
	var/list/plasma = list()					//List of plasma fields
	var/datum/gas_mixture/gas_contents = null	//Plasma must contain a mix of gasses.
	var/exchange_coef = 0.2
	var/decay_coef = 55000
	var/heatpermability = 0						//Do we let the heat escape/exchange with the enviroment or do we contain it. (0 = contain, 0 = exchange)
	var/fusion_heat = 0
	var/datum/fusionUpgradeTable/table
	var/list/coefs
	var/rod_coef = 0
	var/field_coef = 0
	var/obj/machinery/computer/fusion/computer
	var/set_up = 0

/datum/fusion_controller/New()
	fusion_controllers += src
	gas_contents = new /datum/gas_mixture()
	gas_contents.volume = 240
	gas_contents.temperature = T20C
	table = new()

//Standart process cycle
/datum/fusion_controller/proc/process()
	if(set_up)
		checkComponents()
	if(fusion_components.len > 0)
		pass_self()
		updatePlasma()
		calcFusion()
		calcDamage()
		calcConField()
		updateIcons()

//Shuts down reactor by controlled gas venting
/datum/fusion_controller/proc/emergencyVent()
	if(gas_contents.temperature >= 90000)
		gas_contents.temperature = 89000
	leakPlasma()

//Check the individual components for various statuses
/datum/fusion_controller/proc/checkComponents()
	. = 0
	if(fusion_components.len != 13)
		if(gas_contents.temperature > 90000)
			critFail(pick(fusion_components))	//Easteregg for egnineers who think they are safe behind glass
		else
			leakPlasma()
			removePlasma()
		if(!isnull(computer))
			computer.reboot()
		qdel(src)
		return

	var/emmag_nr = 0
	for(var/obj/machinery/power/fusion/comp in fusion_components)
		if(!comp.ready)
			if(gas_contents.temperature > 90000)
				critFail(comp)
			else
				leakPlasma()
				removePlasma()
			if(!isnull(computer))
				computer.reboot()
			qdel(src)
			return
		if(comp.emagged)
			emmag_nr ++
	if(emmag_nr >= 12)
		for(var/obj/machinery/power/fusion/comp in fusion_components)
			comp.locked = 0
	. = 1

//Update the icons
/datum/fusion_controller/proc/updateIcons()
	for(var/obj/machinery/power/fusion/comp in fusion_components)
		comp.update_icon()

//Pass self to the core rod for debug
/datum/fusion_controller/proc/pass_self()
	var/obj/machinery/power/fusion/core/core = fusion_components[13]
	core.controller = src

//Toggle the containment field power scourse
/datum/fusion_controller/proc/toggle_field()
	conPower = !conPower

//Toggle the gas outlet
/datum/fusion_controller/proc/toggle_gas()
	gas = !gas

//Toggle the containment field heat permability
/datum/fusion_controller/proc/toggle_permability()
	heatpermability = !heatpermability
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		p.toggle_heat_transfer()

//Spawns the "plasma" based upon the location of the core rod.
/datum/fusion_controller/proc/generatePlasma()
	var/obj/machinery/power/fusion/plasma/p
	var/obj/machinery/power/fusion/core/core = fusion_components[13]

	for(var/tmp/i in list(-2, 2))
		p = PoolOrNew(/obj/machinery/power/fusion/plasma, core.loc)
		//p = new(core.loc)
		p.x += i
		if(i == 2)
			p.dir = SOUTH
		if(i == -2)
			p.dir = NORTH
		p.fusion_controller = src
		plasma.Add(p)

	for(var/tmp/i in list(-2, 2))
		//p = new(core.loc)
		p = PoolOrNew(/obj/machinery/power/fusion/plasma, core.loc)
		p.y += i
		if(i == 2)
			p.dir = EAST
		if(i == -2)
			p.dir = WEST
		p.fusion_controller = src
		plasma.Add(p)

//Update the status of the plasma.. among other things -_-'
/datum/fusion_controller/proc/updatePlasma()
	var/obj/machinery/power/fusion/core/core = fusion_components[13]
	if(plasma.len == 0 && gas)
		generatePlasma()

	if(gas)
		pumpPlasma()

	if(plasma.len == 0 || isnull(gas_contents) || gas_contents.total_moles < 1)
		return

	for(var/obj/machinery/power/fusion/comp in fusion_components)
		if(comp.anchored == 0)
			leakPlasma()
			if(gas_contents.temperature > 90000)	//We are at fusion temp EXPLODE!
				critFail()
				return

	if(!confield)
		if(gas_contents.temperature < 75000)
			leakPlasma()
			removePlasma()
			gas = 0
		else
			critFail(pick(fusion_components))
		return

	core.decay()

	//heat up plasma and temp sanity check
	var/tmp/heatdif = core.heat
	//The beams temerature is about 100k deg so we cap input there.
	if(gas_contents.temperature >= 100000)
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

//Pump plasma from the ring tanks into the "field"
/datum/fusion_controller/proc/pumpPlasma()
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		pump_gas(r, r.get_tank_content(), gas_contents, r.get_tank_moles())
	gas_contents.update_values()
	coefs = table.gas_coef(gas_contents)

//Pump plasma back into rings.
/datum/fusion_controller/proc/drainPlasma()
	gas_contents.divide(4)
	//world << "Total gass moles of devide mix: [gas_contents.total_moles]"
	var/datum/gas_mixture/tank_mix
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		tank_mix = new()
		tank_mix.temperature = gas_contents.temperature
		tank_mix.add(gas_contents)
		//world << "Total gass moles of tank mix: [tank_mix.total_moles]"
		r.set_tank_content(tank_mix)
	gas_contents = new()
	removePlasma()

//Remove plasma objects.
/datum/fusion_controller/proc/removePlasma()
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		qdel(p)
	plasma = list()

//If the containment field get disabled.. bad stuff.
//This can also be used to flood the room in case of an emerency so the reactor does not go boom.
/datum/fusion_controller/proc/leakPlasma()
	var/tmp/dif = gas_contents.temperature/4
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		pump_gas(p, gas_contents, p.loc.return_air(), gas_contents.total_moles/4)
		gas_contents.temperature -= dif
	gas = 0
	gas_contents = new()

//Calculate plasma passive heat decay.
/datum/fusion_controller/proc/calcDecay(var/temp)
	. = 2**(temp/(decay_coef))*(1-field_coef)

//Containment field calculations and adjustment.. also sprite overlay.
/datum/fusion_controller/proc/calcConField()
	if(confield)
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.overlays = list(image(p.icon, "field_overlay"))
		for(var/obj/machinery/power/fusion/comp in fusion_components)
			comp.on = 1
			comp.locked = 1		//Prevent the components from beeing wrenched out of place.
	else
		for(var/obj/machinery/power/fusion/plasma/p in plasma)
			p.overlays.Cut()
		for(var/obj/machinery/power/fusion/comp in fusion_components)
			comp.on = 0
			comp.locked = 0

	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		if(conPower)
			//Power check here !
			r.battery = min(r.battery + 150, 5000)
		r.battery = max(r.battery - 25, 0)
		confield = r.battery

//When does fusion happen ?
/datum/fusion_controller/proc/calcFusion()
	if(plasma.len == 0 || isnull(gas_contents))
		return
	if(gas_contents.temperature < 90000)
		return
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		var/change = min(((gas_contents.temperature/500000)*100), 25)			//This needs tweaking also with gass mixtures
		change = change * Clamp(coefs["fuel"], 0, 2)
		if(prob(change))
			fusionEvent(p)

//Fusion event, generates heat neutrons wich generate energy via collectors.
/datum/fusion_controller/proc/fusionEvent(obj/machinery/power/fusion/plasma/p)
	var/tmp/neutrons = 1000						//Base neutrons
	var/tmp/heat = 2000							//Base heat
	var/tmp/heat_absorbed = heat*coefs["heat_neutron"]
	var/tmp/neutrons_absorbed = neutrons*coefs["heat_neutron"]
	var/tmp/rod_neutrons = neutrons*rod_coef	//Neutrons generated via the corner neutron rods.
	var/tmp/rod_heat = heat*(1-rod_coef)
	var/tmp/gas_neutrons = neutrons*coefs["neutron"] + heat*coefs["heat_neutron"] - neutrons_absorbed
	var/tmp/gas_heat = heat*coefs["heat"] + neutrons*coefs["neutron_heat"] - heat_absorbed
	fusion_heat = rod_heat + gas_heat	//The rod is not the middle rod but the nuetron rods in the corners.
	p.transfer_energy(rod_neutrons + gas_neutrons)
	p.spark()
	p.set_light(3, 5, "#E6FFFF")
	spawn()
		new/obj/effect/effect/plasma_ball(get_turf(p))
		var/list/targets = list()
		for(var/mob/living/carbon/human/M in oview(p, 5))
			if(!insulated(M))
				targets += M
		if(targets.len > 0)
			var/mob/living/carbon/human/M = pick(targets)
			arc(M, p)
			M.electrocute_act(rand(20, 40), p)
	//Neutrons effect the containment field, more neutrons = more power but also more were on the field
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		r.battery -= (neutrons/10)*(1+field_coef)

/datum/fusion_controller/proc/insulated(var/mob/living/carbon/human/m)
	if(isnull(m.head) || isnull(m.wear_suit))
		return 0
	if(!m.head.siemens_coefficient >= 0.9 || !m.wear_suit.siemens_coefficient >= 0.9)
		return 0
	return 1

/datum/fusion_controller/proc/arc(obj/T, obj/S)
	if(isnull(T))
		return
	var/datum/effect/effect/system/lightning_bolt/bolt = PoolOrNew(/datum/effect/effect/system/lightning_bolt)
	bolt.start(S, T, size = 1)
	playsound(S.loc, pick( 'sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg'), 100, 1)

//Calculate if we should do damage to the rings according to heat of the gas.
//A random ring will take 1 point of damage for every 5000 deg above 1 mil deg.
/datum/fusion_controller/proc/calcDamage()
	if(gas_contents.temperature > 1000000)
		var/i = pick(list(1,2,3,4,5,6,7,8,9,10,11,12))
		var/obj/machinery/power/fusion/component = fusion_components[i]
		component.damage += (gas_contents.temperature - 1000000)/5000

	for(var/obj/machinery/power/fusion/component in fusion_components)
		if(component.damage > 500 && component.damage < 800)
			//warning

		else if(component.damage > 800 && component.damage < 950)
			//Critical warning

		else if(component.damage > 999)
			//critically fail
			critFail()

//Critically fail in an explosion .. or worse.
/datum/fusion_controller/proc/critFail(var/obj/o)
	if(gas_contents.temperature > 600000)
		new/obj/fusion_ball(o.loc)
	gas = 0
	leakPlasma()
	removePlasma()
	spawn()
		explosion(get_turf(o), 2, 4, 10, 15)
	//You are really deep in the shit now boi!


//LONG LIVE SPAGETTI !
//This finds all the components in a efficient but really clumsy code wise way.
/datum/fusion_controller/proc/findComponents(obj/machinery/power/fusion/core/c)
	var/tmp/list/temp_list = list()
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
			continue

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
			continue

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
			continue

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
	for(var/obj/machinery/power/fusion/comp in temp_list)
		if(!comp.ready)
			return
		comp.fusion_controller = src
	//Calculating component coefs
	for(var/obj/machinery/power/fusion/ring_corner/r in temp_list)
		if(isnull(r.rod) || isnull(r.crystal))
			return
		rod_coef += table.rod_coef(r.rod)
		field_coef += table.field_coef(r.crystal)
	rod_coef = rod_coef/4
	field_coef = field_coef/4

	fusion_components = temp_list
	set_up = 1
	return 1

/datum/fusion_controller/proc/addComp(var/obj/machinery/computer/fusion/comp)
	fusion_components.Add(comp)