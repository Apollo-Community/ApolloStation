/*
	Critical failure:

*/

/datum/sm_control
	var/base_power = 0 	// The power output that the engine will stabilize at, in kW
	var/decay = 50 // Percent per minute
	var/o2_turbo_multiplier = 0 // How much oxygen will multiply power and heat output by, per mole
	var/o2_requirement = 0 // How much oxygen is required to keep the engine from critically failing, as a percent of the total gas composition
	var/suffocation_damage = 0 // How much damage will be done if the engine doesn't have enough O2
	var/crit_fail_chance = 0 // The chance that a critical fail will happen per minute if the engine is starving for oxygen
	var/crit_fail_damage = 0 // the amount of damage done by a critical failure
	var/co2_heat_multiplier = 0 // The multiplier that CO2 increases heat production by, per mole
	var/n2o_power_loss = 0 // The rate that N2O decreases power output, per mole
	var/phoron_heal_rate = 0 // The rate that phoron heals the core, per mole
	var/emitter_damage = 0 // The amount of damage the emitter does per hit
	var/heat_damage_level = 1000 // The temperature at which heat will start damaging the crystal
	var/damage_per_degree = 1 // How much damage per degree over heat_damage_level will cause
	var/explosions_size = 25 // The size of the explosion
	var/delamination_size = 25 // The size of the vorbis wave burst
	var/vacuum_damage = 0 // The amount of damage done when the SM is sitting in a vacuum
	var/thermal_factor = 0 // The amount of heat released to the environment this tick
	var/consumption_rate = 10 // The amount of gas consumed this tick
	var/psionic_power = 10 // The amount of hallucination that will be added if someone looks at it
	var/radiation_power = 20 // The amount of radiation released
	var/pull_time = 15 // the amount of time in seconds that the supermatter will pull in before exploding
	var/color = ""
	var/color_name = ""

/datum/sm_control/level_1
	base_power = 500000
	o2_turbo_multiplier = 1.5/CANISTER_MOLARITY
	n2o_power_loss = 10000
	phoron_heal_rate = 100/CANISTER_MOLARITY
	color = "SM_DEFAULT_COLOR"
	color_name = "green"

/datum/sm_control/level_2
	base_power = 800000
	o2_turbo_multiplier = 1.6/CANISTER_MOLARITY
	n2o_power_loss = 9000
	phoron_heal_rate = 80/CANISTER_MOLARITY
	emitter_damage = 10
	color = "#00FF99"
	color_name = "cyan"
	delamination_size = 30
	vacuum_damage = 10

/datum/sm_control/level_3
	base_power = 1400000
	o2_turbo_multiplier = 1.7/CANISTER_MOLARITY
	co2_heat_multiplier = 1.1/CANISTER_MOLARITY
	n2o_power_loss = 8000
	phoron_heal_rate = 60/CANISTER_MOLARITY
	emitter_damage = 20
	color = "#0099FF"
	color_name = "blue"
	explosions_size = 25
	delamination_size = 35
	vacuum_damage = 25

/datum/sm_control/level_4
	base_power = 2600000
	o2_turbo_multiplier = 1.8/CANISTER_MOLARITY
	co2_heat_multiplier = 1.2/CANISTER_MOLARITY
	n2o_power_loss = 7000
	phoron_heal_rate = 40/CANISTER_MOLARITY
	emitter_damage = 30
	color = "#6600FF"
	color_name = "purple"
	explosions_size = 25
	delamination_size = 40
	vacuum_damage = 50

/datum/sm_control/level_5
	base_power = 5200000
	o2_turbo_multiplier = 1.9/CANISTER_MOLARITY
	o2_requirement = 0.10
	crit_fail_chance = 0.01
	co2_heat_multiplier = 1.3/CANISTER_MOLARITY
	n2o_power_loss = 5000
	phoron_heal_rate = 20/CANISTER_MOLARITY
	emitter_damage = 40
	color = "#FF00FF"
	color_name = "pink"
	explosions_size = 45
	delamination_size = 45
	vacuum_damage = 60

/datum/sm_control/level_6
	base_power = 10400000
	o2_turbo_multiplier = 2.0/CANISTER_MOLARITY
	o2_requirement = 0.15
	crit_fail_chance = 0.05
	co2_heat_multiplier = 1.4/CANISTER_MOLARITY
	n2o_power_loss = 3000
	phoron_heal_rate = 0/CANISTER_MOLARITY
	emitter_damage = 50
	color = "#FF3399"
	color_name = "magenta"
	explosions_size = 45
	delamination_size = 55
	vacuum_damage = 70

/datum/sm_control/level_7
	base_power = 20800000
	o2_turbo_multiplier = 2.1/CANISTER_MOLARITY
	o2_requirement = 0.20
	crit_fail_chance = 0.1
	co2_heat_multiplier = 1.5/CANISTER_MOLARITY
	n2o_power_loss = 1000
	phoron_heal_rate = 0/CANISTER_MOLARITY
	emitter_damage = 60
	color = "#FFFF00"
	color_name = "yellow"
	explosions_size = 45
	delamination_size = 65
	vacuum_damage = 80

/datum/sm_control/level_8
	base_power = 41600000
	o2_turbo_multiplier = 2.2/CANISTER_MOLARITY
	o2_requirement = 0.25
	crit_fail_chance = 0.5
	co2_heat_multiplier = 1.6/CANISTER_MOLARITY
	n2o_power_loss = 0000
	phoron_heal_rate = 0/CANISTER_MOLARITY
	emitter_damage = 70
	color = "#FF6600"
	color_name = "orange"
	explosions_size = 45
	delamination_size = 75
	vacuum_damage = 90

/datum/sm_control/level_9
	base_power = 83200000
	o2_turbo_multiplier = 2.3/CANISTER_MOLARITY
	o2_requirement = 0.3
	crit_fail_chance = 1.0
	co2_heat_multiplier = 1.7/CANISTER_MOLARITY
	n2o_power_loss = -2000
	phoron_heal_rate = -10/CANISTER_MOLARITY
	emitter_damage = 80
	color = "#FF0000"
	color_name = "red"
	explosions_size = 45
	delamination_size = 85
	vacuum_damage = 100

/*
/sm_control/var/list/settings = list()
/sm_control/var/list/bitflags = list("1","2","4","8","16","32","64","128","256","512","1024")

/sm_control/New()
	. = ..()
	settings = vars.Copy()

	var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
	for(var/V in D.vars)
		settings -= V

	for(var/V in settings)
		if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC") || findtextEx(V,"_METHOD"))
			settings -= V

	settings -= "settings"
	settings -= "bitflags"

/sm_control/proc/ChangeSettingsDialog(mob/user,list/L)
	//var/which = input(user,"Choose a setting:") in L
	var/dat = ""
	for(var/ch in L)
		if(findtextEx(ch,"_RANDOM") || findtextEx(ch,"_DESC") || findtextEx(ch,"_METHOD") || findtextEx(ch,"_NAME")) continue
		var/vw
		var/vw_desc = "No Description."
		var/vw_name = ch
		vw = vars[ch]
		if("[ch]_DESC" in vars) vw_desc = vars["[ch]_DESC"]
		if("[ch]_NAME" in vars) vw_name = vars["[ch]_NAME"]
		dat += "<b>[vw_name] = [vw]</b> <A href='?src=\ref[src];changevar=[ch]'>\[Change\]</A><br>"
		dat += "<i>[vw_desc]</i><br><br>"
	user << browse(dat,"window=settings")

/sm_control/Topic(href,href_list)
	if("changevar" in href_list)
		ChangeSetting(usr,href_list["changevar"])

/sm_control/proc/ChangeSetting(mob/user,ch)
	var/vw
	var/how = "Text"
	var/display_description = ch
	vw = vars[ch]
	if("[ch]_NAME" in vars)
		display_description = vars["[ch]_NAME"]
	if("[ch]_METHOD" in vars)
		how = vars["[ch]_METHOD"]
	else
		if(isnum(vw))
			how = "Numeric"
		else
			how = "Text"
	var/newvar = vw
	switch(how)
		if("Numeric")
			newvar = input(user,"Enter a number:","Settings",newvar) as num
		if("Bit Flag")
			var/flag = input(user,"Toggle which bit?","Settings") in bitflags
			flag = text2num(flag)
			if(newvar & flag)
				newvar &= ~flag
			else
				newvar |= flag
		if("Toggle")
			newvar = !newvar
		if("Text")
			newvar = input(user,"Enter a string:","Settings",newvar) as text
		if("Long Text")
			newvar = input(user,"Enter text:","Settings",newvar) as message
	vw = newvar
	vars[ch] = vw
	if(how == "Toggle")
		newvar = (newvar?"ON":"OFF")
	world << "\blue <b>[key_name(user)] changed the setting [display_description] to [newvar].</b>"
	ChangeSettingsDialog(user,settings)

/sm_control/proc/RandomizeWithProbability()
	for(var/V in settings)
		var/newvalue
		if("[V]_RANDOM" in vars)
			if(isnum(vars["[V]_RANDOM"]))
				newvalue = prob(vars["[V]_RANDOM"])
			else if(istext(vars["[V]_RANDOM"]))
				newvalue = roll(vars["[V]_RANDOM"])
			else
				newvalue = vars[V]
		V = newvalue

/sm_control/proc/SetDefault(var/mob/user)
	var/list/setting_choices = list("Supermatter - Standard", "Supermatter - Easy", "Supermatter - Hard", "Supermatter - EXTREME", "Supermatter - SIMPLE MODE", \
	                                "Supermatter - ADVANCED MODE", "Power - Standard", "Power - LESS", "Power - MORE", "Danger - Standard", \
	                                "Danger - LESS", "Danger - MORE")
	var/def = input(user, "Which of these presets should be used?") as null|anything in setting_choices
	if(!def)
		return
	switch(def)
		if("Supermatter - Standard")
			base_power = 400
			fusion_power = 1.3
			fusion_stability = 10
			crystal_rate = 10
			crit_stability = 100
			thermal_factor = 350
			crit_temp = 800
			consumption_rate = 10
			gas_rate = 5
			psionic_power = 10
			radiation_power = 10
			warning_delay = 30
			detonate_delay = 10
			explosion_size = 5
			crit_danger = 100
			damage_factor = 1
			suffocation_moles = 5
			heat_damage = 10
			decay_rate = 50
			safe_level = 2

		if("Supermatter - Easy")
			base_power = 400
			fusion_power = 1.2
			fusion_stability = 100
			crystal_rate = 100
			crit_stability = 1000
			thermal_factor = 250
			crit_temp = 800
			consumption_rate = 10
			gas_rate = 10
			psionic_power = 5
			radiation_power = 5
			warning_delay = 10
			detonate_delay = 30
			explosion_size = 3
			crit_danger = 10
			damage_factor = 0.5
			suffocation_moles = 1
			heat_damage = 5
			decay_rate = 25
			safe_level = 2

		if("Supermatter - Hard")
			base_power = 400
			fusion_power = 1.6
			fusion_stability = 10
			crystal_rate = 5
			crit_stability = 10
			thermal_factor = 350
			crit_temp = 800
			consumption_rate = 10
			gas_rate = 5
			psionic_power = 10
			radiation_power = 10
			warning_delay = 60
			detonate_delay = 10
			explosion_size = 6
			crit_danger = 200
			damage_factor = 2
			suffocation_moles = 7
			heat_damage = 20
			decay_rate = 75
			safe_level = 2

		if("Supermatter - EXTREME")
			base_power = 400
			fusion_power = 2
			fusion_stability = 0
			crystal_rate = 1
			crit_stability = 0
			thermal_factor = 350
			crit_temp = 500
			consumption_rate = 10
			gas_rate = 10
			psionic_power = 15
			radiation_power = 20
			warning_delay = 60
			detonate_delay = 10
			explosion_size = 8
			crit_danger = 500
			damage_factor = 5
			suffocation_moles = 10
			heat_damage = 30
			decay_rate = 100
			safe_level = 1

		if("Supermatter - SIMPLE MODE")
			safe_level = 10

		if("Supermatter - ADVANCED MODE")
			safe_level = 0

		if("Power - STANDARD")
			base_power = 400
			fusion_power = 1.3
			decay_rate = 50

		if("Power - LESS")
			base_power = max(50, base_power-50)
			fusion_power = max(1, fusion_power-0.05)
			decay_rate += 10

		if("Power - MORE")
			base_power += 50
			fusion_power += 0.05
			decay_rate = max(0, decay_rate-10)

		if("Danger - STANDARD")
			psionic_power = 10
			radiation_power = 10
			warning_delay = 30
			detonate_delay = 10
			explosion_size = 5
			crit_danger = 100

		if("Danger - LESS")
			psionic_power = max(0, psionic_power-5)
			radiation_power = max(0, radiation_power-5)
			explosion_size = max(0, explosion_size-0.5)
			crit_danger = max(0, crit_danger-25)

		if("Danger - MORE")
			psionic_power += 5
			radiation_power += 5
			explosion_size += 0.5
			crit_danger += 25


	world << "\blue <b>[key_name(user)] changed the global supermatter settings to \"[def]\"</b>"

*/