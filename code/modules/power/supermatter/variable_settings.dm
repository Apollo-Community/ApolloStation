
var/global/sm_control/smvsc = new

/sm_control
	var/base_power = 400
	var/base_power_NAME = "Supermatter - Base Power"
	var/base_power_DESC = "How many kilowatts a standard engine will produce with an ideal setup."

	var/fusion_power = 1.3
	var/fusion_power_NAME = "Supermatter - Fusion Power"
	var/fusion_power_DESC = "Rate at which efficiency increases per fusion."

	var/fusion_stability = 10
	var/fusion_stability_NAME = "Supermatter - Fusion Stability"
	var/fusion_stability_DESC = "Amount of stability gained during fusion."

	var/crystal_rate = 10
	var/crystal_rate_NAME = "Supermatter - Growth Rate"
	var/crystal_rate_DESC = "Rate at which the supermatter crystal is able to regenerate."

	var/crit_stability = 100
	var/crit_stability_NAME = "Supermatter - Critical Stability"
	var/crit_stability_DESC = "How likely the engine is to have a critical failure."

	var/thermal_factor = 350
	var/thermal_factor_NAME = "Supermatter - Thermal Factor"
	var/thermal_factor_DESC = "Amount of heat produced by the engine."

	var/crit_temp = 800
	var/crit_temp_NAME = "Supermatter - Critical Temperature"
	var/crit_temp_DESC = "Temperature in Kelvin at which the supermatter will start to take damage."

	var/consumption_rate = 10
	var/consumption_rate_NAME = "Supermatter - Consumption Rate"
	var/consumption_rate_DESC = "Affects the speed at which the supermatter will consume gasses."

	var/gas_rate = 5
	var/gas_rate_NAME = "Supermatter - Gas Value"
	var/gas_rate_DESC = "The amount of power produced per mole of gas."

	var/psionic_power = 10
	var/psionic_power_NAME = "Supermatter - Psionic Power"
	var/psionic_power_DESC = "How powerful the psionic bursts produced by the engine are."

	var/radiation_power = 10
	var/radiation_power_NAME = "Supermatter - Radiation Power"
	var/radiation_power_DESC = "How powerful the radiation bursts produced by the engine are."

	var/warning_delay = 30
	var/warning_delay_NAME = "Supermatter - Warning Delay"
	var/warning_delay_DESC = "Time in seconds between supermatter alert messages."

	var/detonate_delay = 10
	var/detonate_delay_NAME = "Supermatter - Explosion Delay"
	var/detonate_delay_DESC = "Time in seconds to escape the supermatter blast."

	var/explosion_size = 5
	var/explosion_size_NAME = "Supermatter - Explosion Size"
	var/explosion_size_DESC = "The size of the supermatter explosion."

	var/crit_danger = 100
	var/crit_danger_NAME = "Supermatter - Critical Danger"
	var/crit_danger_DESC = "The amount of danger presented by a critical failure."

	var/damage_factor = 1
	var/damage_factor_NAME = "Supermatter - Damage Factor"
	var/damage_factor_DESC = "How much damage the supermatter is able to take."

	var/suffocation_moles = 5
	var/suffocation_moles_NAME = "Supermatter - Suffocation Moles"
	var/suffocation_moles_DESC = "How much oxygen the supermatter requires in order to function."

	var/heat_damage = 10
	var/heat_damage_NAME = "Supermatter - Heat Damage"
	var/heat_damage_DESC = "The amount of damage the engine will take from overheating."

	var/decay_rate = 50
	var/decay_rate_NAME = "Supermatter - Decay Rate"
	var/decay_rate_DESC = "The rate at which the supermatter loses power."

	var/safe_level = 2
	var/safe_level_NAME = "Supermatter - Safe Level"
	var/safe_level_DESC = "The fusion level at which the engine enters advanced mode."

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