/datum/round_stats
	// The description for the stat
	var/list/descriptions = list( "deaths" = "Crew Deaths: ",
								  "clones" = "Crew Reconstituted: ",
								  "dispense_volume" = "Chemicals Vended Volume: ",
								  "bombs_exploded" = "Bombs Exploded: ",
								  "vended" = "Items Vended: ",
								  "break_time" = "Time Spent on Break: ",
								  "run_distance" = "Crew Running Distance: ",
								  "blood_mopped" = "Total Blood Mopped: ",
								  "damage_cost" = "Structural Damages: ",
								  "monkey_deaths" = "Monkeys Inhumanely Slain: ",
								  "spam_blocked" = "Spam Messages Blocked: ",
								  "people_slipped" = "Slippery Floor Signs Ignored: ",
								  "doors_opened" = "Total Time Spent Waiting for Doors: ",
								  "guns_fired" = "Total \"Warning\" Shots Fired: ",
								  "beepsky_beatings" = "Justice Served: ",
								  "doors_welded" = "Doors \"Locked\": ",
								  "total_kwh" = "Total Power Produced: ",
								  "artifacts" = "Artifacts Excavated: ",
								  "cargo_profit" = "Cargo Profit: ",
								 )

	// The actual stat value
	var/list/stats = list( "deaths" = 0,
						   "clones" = 0,
						   "dispense_volume" = 0, // Total volume of chemicals dispensed by chem dispensers
						   "bombs_exploded" = 0, // Total number of bombs exploded
						   "vended" = 0, // Total number of items vended from vending machines
						   "run_distance" = 0, // Total distance run in meters
						   "blood_mopped" = 0, // Total volume of blood mopped up in liters
						   "damage_cost" = 0, // Cost of all station damages
						   "break_time" = 0, // Total time spent AFK
						   "monkey_deaths" = 0, // Total number of monkeys killed
						   "spam_blocked" = 0, // PDA messages blocked by spam filter
						   "people_slipped" = 0, // Total number of times people have slipped
						   "doors_opened" = (-30*0.3), // Total number of times doors have been opened
						   "guns_fired" = 0, // Total number of times any type of gun has been fired
						   "beepsky_beatings" = 0, // Total number of times beepsky arrested someone
						   "doors_welded" = 0, // Total number of doors welded
						   "total_kwh" = 0, // Total kilowatt/hours produced by engineering
						   "artifacts" = 0, // Total number of artifacts dug up
						   "cargo_profit" = 0, // Profit made from cargobay
						   )

	// Just add any stats that need units
	var/list/units = list( "dispense_volume" = " L",
						   "bombs_exploded" = " accidents",
						   "vended" = " junk foods",
						   "run_distance" = " marathons",
						   "blood_mopped" = " L",
						   "spam_blocked" = " messages",
						   "doors_opened" = " seconds",
						   "guns_fired" = " \"warning\" shots",
						   "beepsky_beatings" = " beatings",
						   "total_kwh" = " kW/h",
						   "artifacts" = " alien artifacts",
						   "break_time" = "minutes",
						   )

/datum/round_stats/proc/increase_stat(var/stat_name, var/amount = 1)
	stats[stat_name] += amount

/datum/round_stats/proc/display(var/client/C)
	var/work_time = round( world.time/10 )*living_mob_list.len
	var/productivity = max(round(100*(1-(stats["break_time"]/work_time))),0) // Productivity is just percentage of time spent not AFK
	productivity = max(0,min(99.99, productivity - (stats["deaths"]*3 + stats["clones"]*2 + stats["bombs_exploded"]*5 + stats["vended"] + stats["people_slipped"]*2) + (stats["beepsky_beatings"]*2 + stats["blood_mopped"] + stats["spam_blocked"])))

	var/datum/nanoui/ui = null
	var/data[0]

	data["productivity_desc"] = "Crew Productivity: "
	data["productivity"] = "[productivity]%"
	data["structural_desc"] = descriptions["damage_cost"]
	data["structural"] = stats["damage_cost"]
	data["deaths_desc"] = descriptions["deaths"]
	data["deaths"] = stats["deaths"]
	data["clones_desc"] = descriptions["clones"]
	data["clones"] = stats["clones"]

	var/list/chosen_stats = list("deaths", "clones", "damage_cost") // stats that have already been chosen to be displays

	for( var/i = 0, i < 10, i++ )
		var/stat = pick( stats )
		if(!(stat in chosen_stats))
			chosen_stats.Add(stat)

			data["stat_[i]_desc"] = descriptions[stat]
			data["stat_[i]"] = stats[stat]
			if( units[stat] )
				data["stat_[i]_unit"] = units[stat]
			else
				data["stat_[i]_unit"] = ""
		else
			i--

	ui = nanomanager.try_update_ui(C, C, "main", ui, data, 1)
	if (!ui)
		ui = new(C, C, "main", "stats.tmpl", "End Round Stats", 500, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

datum/round_stats/proc/call_stats()
	for(var/client/C in clients)
		statistics.display(C)