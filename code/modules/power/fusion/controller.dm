/*
*	Regulates the fusion engine and this components.
*/
#define TM_SAFE_ALERT "Con"
/datum/fusion_controller
	var/list/fusion_components = list()			//List of components making up the fusion reactor.
	var/mode = 1								//Mode, direct = 0, indirect = 1.
	var/gas = 0									//Is the gas release open.
	var/confield = 0
	var/conPower = 0							//Is the containment field active.
	var/list/plasma = list()					//List of plasma fields
	var/datum/gas_mixture/gas_contents = null	//Plasma must contain a mix of gasses.
	var/decay_coef = 80000						//The direct heat decal is diveded by this for the actual heat decay
	var/heatpermability = 0						//Do we let the heat escape/exchange with the enviroment or do we contain it. (0 = contain, 0 = exchange)
	var/fusion_heat = 0							//Fusion heat generated last tick
	var/datum/fusionUpgradeTable/table			//Datum with gas, rod and crystal coefs
	var/list/coefs								//List with gas and color coefs
	var/rod_coef = 0							//What effect does the rod compo do on neutron/heat generation
	var/field_coef = 0							//Field coef, how much does the field regen extra
	var/obj/machinery/computer/fusion/computer	//The computer that this is linked to
	var/set_up = 0
	var/lastwarning = 0
	var/warning_delay = 600 	//10 sec between warnings
	var/confield_archived = 0
	var/safe_warned = 0
	var/obj/item/device/radio/radio 	//For radio warnings
	var/rod_insertion = 0.5		//How far is the rod inserted, has effect on heat, neutrons and neutron damage generation
	var/message_delay
	var/safe_warn
	var/max_field_coef = 1
	var/event_color = ""		//Color of fusion events
	var/neutrondam_coef = 5		//Devide neutrons by this for damage to shields this will keep it stable at 50 rod insetion at normal activity.
	var/power_coef = 16.5

/datum/fusion_controller/New()
	fusion_controllers += src
	gas_contents = new /datum/gas_mixture()
	gas_contents.volume = 240
	gas_contents.temperature = T20C
	table = new()
	radio = new(src)

/datum/fusion_controller/Destroy()
	qdel(radio)
	..()

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
		announce_warning()	//Announce a warning if the confield is dropping below 50%
		confield_archived = confield
		updateIcons()

//Shuts down reactor by controlled gas venting
/datum/fusion_controller/proc/emergencyVent()
	if(gas_contents.temperature >= 90000)
		gas_contents.temperature = 89000
	leakPlasma()
	removePlasma()

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
		if(!comp.ready || comp.stat == BROKEN)
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

//Reset the force field for maintenance
/datum/fusion_controller/proc/reset_field()
	conPower = 0
	confield = 0

//Neutron Rod insertion percentage
/datum/fusion_controller/proc/change_rod_insertion(change)
	rod_insertion = Clamp(rod_insertion + change, 0, 1)

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
	//The arc emitters temerature is about 100k deg so we cap input there.
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
	if(isnull(table))
		return
	coefs = table.gas_coef(gas_contents)
	if(isnull(event_color) || isnull(gas_contents))
		return
	var/tmp/gas_color = table.gas_color(gas_contents, event_color)
	if(isnull(gas_color))
		return
	//Gas has effect on the color of fusion events.
	event_color = BlendRGB(event_color, gas_color, 0.5)

//Pump plasma back into rings.
/datum/fusion_controller/proc/drainPlasma()
	gas_contents.divide(4)
	var/datum/gas_mixture/tank_mix
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		tank_mix = new()
		tank_mix.temperature = gas_contents.temperature
		tank_mix.add(gas_contents)
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
	. = (2**(temp/(decay_coef)))+((0.00005*temp)**2)

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

	var/tmp/tmp_confield = confield
	confield = 0
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		r.charge()
		if(conPower)
			tmp_confield += r.field_energy()
	if(!isnull(coefs))
		tmp_confield = tmp_confield*coefs["shield"] + tmp_confield*field_coef
	confield = Clamp(tmp_confield, 0, 40000 + 1000*field_coef)

//When does fusion happen ?
/datum/fusion_controller/proc/calcFusion()
	if(plasma.len == 0 || isnull(gas_contents))
		return
	if(gas_contents.temperature < 90000)
		return
	for(var/obj/machinery/power/fusion/plasma/p in plasma)
		var/change = min(((gas_contents.temperature/500000)*100), 25)			//This needs tweaking also with gass mixtures
		change = change * coefs["fuel"] * coefs["dampening"]
		if(prob(change))
			fusionEvent(p)

//Fusion event, generates heat neutrons wich generate energy via collectors.
/datum/fusion_controller/proc/fusionEvent(obj/machinery/power/fusion/plasma/p)
	//These base values should be class values !
	var/tmp/neutrons = 1000						//Base neutrons
	var/tmp/heat = 2000							//Base heat
	neutrons += (heat*coefs["heat_neutron"] - neutrons*coefs["neutron_heat"])*coefs["neutron"] + neutrons*rod_coef
	heat += neutrons*coefs["neutron_heat"] - heat*coefs["heat_neutron"] + heat*rod_coef
	fusion_heat = heat*rod_insertion
	p.transfer_energy(neutrons*rod_insertion*power_coef)
	spawn()
		p.spark()
		p.set_light(3, 5, event_color)
		var/tmp/obj/effect/effect/plasma_ball/pball = new(get_turf(p))
		pball.set_color(event_color)

		var/list/targets = list()
		for(var/mob/living/carbon/human/M in oview(p, 5))
			if(!insulated(M))
				targets += M
		if(targets.len > 0)
			var/mob/living/carbon/human/M = pick(targets)
			arc(M, p)
			M.apply_damage(rand(10, 20), damagetype = BURN)
			M.apply_effect(rand(10, 20), effecttype = STUN)

	//Neutrons effect the containment field, more neutrons = more power but also more were on the field
	for(var/obj/machinery/power/fusion/ring_corner/r in fusion_components)
		confield -= (neutrons/neutrondam_coef)*rod_insertion

	if(coefs["explosive"] && prob(5))
		critFail(p)

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
	new/obj/effect/effect/sparks(get_turf(T))

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
			critFail(component)

//Critically fail in an explosion .. or worse.
/datum/fusion_controller/proc/critFail(var/obj/o)
	if(isnull(o))
		return
	if(gas_contents.temperature > 250000)
		//You are really deep in the shit now boi!
		new/obj/fusion_ball(o.loc)
	gas = 0
	leakPlasma()
	removePlasma()
	spawn()
		explosion(get_turf(o), 2, 4, 10, 15)

/datum/fusion_controller/proc/announce_warning()
	var/tmp/alert_msg = "Warning Tokamak containment field integrity at [round(confield/400)]%"
	if(confield < 20000)
		if(confield < confield_archived) // The damage is still going up sinse last calc
			safe_warn = 1
		else if (safe_warn)
			safe_warn = 0 // We are safe, warn only once
			alert_msg = TM_SAFE_ALERT
		else
			alert_msg = null
		if(alert_msg && world.timeofday >= message_delay)
			message_delay = world.timeofday + 15
			radio.autosay(alert_msg, "Tokamak Monitor")

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
		if(isnull(event_color) || event_color == "")
			event_color = table.rod_color(r.rod)
		else
			event_color = BlendRGB(event_color, table.rod_color(r.rod), 0.5)
		rod_coef += table.rod_coef(r.rod)
		field_coef += table.field_coef(r.crystal)
	rod_coef = rod_coef/4
	field_coef = field_coef/4

	fusion_components = temp_list
	set_up = 1
	return 1

/datum/fusion_controller/proc/addComp(var/obj/machinery/computer/fusion/comp)
	fusion_components.Add(comp)