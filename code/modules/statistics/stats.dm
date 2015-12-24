/datum/round_stats
	// The description for the stat
	var/list/descriptions = list( "deaths" = "Crew Deaths: ",
								  "clones" = "Crew Reconstituted: ",
								  "dispense_volume" = "Chemicals Vended: ",
								  "bombs_exploded" = "Bombs Exploded: ",
								  "vended" = "Items Vended: ",
								  "break_time" = "Time Spent on Break: ",
								  "run_distance" = "Crew Ran: ",
								  "blood_mopped" = "Total Blood Mopped: ",
								  "damage_cost" = "Structural Damages: ",
								  "monkey_deaths" = "Monkeys Slain: ",
								  "spam_blocked" = "Spam Blocked: ",
								  "people_slipped" = "Wet Signs Ignored: ",
								  "doors_opened" = "Waiting for Doors: ",
								  "guns_fired" = "Total \"Warning\" Shots: ",
								  "beepsky_beatings" = "Justice Served: ",
								  "doors_welded" = "Doors \"Locked\": ",
								  "total_kwh" = "Power Produced: ",
								  "artifacts" = "Artifacts Found: ",
								  "cargo_profit" = "Cargo Profit: ",
								  "trash_vented" = "Space Trash Created: ",
								  "ai_follow" = "People Watched: ",
								 )

	// The actual stat value
	var/list/stats = list( "productivity" = 0,
						   "deaths" = 0,
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
						   "trash_vented" = 0, // Trash vented to space
						   "ai_follow" = 0,
						   )

	// Just add any stats that need units
	var/list/units = list( "dispense_volume" = " L",
						   "vended" = " junk foods",
						   "run_distance" = " marathons",
						   "blood_mopped" = " L",
						   "spam_blocked" = " messages",
						   "doors_opened" = " seconds",
						   "guns_fired" = " \"warning\" shots",
						   "beepsky_beatings" = " beatings",
						   "total_kwh" = " kW/h",
						   "artifacts" = " alien artifacts",
						   "break_time" = " minutes",
						   "ai_follow" = " people spied on",
						   )

/datum/round_stats/proc/increase_stat(var/stat_name, var/amount = 1)
	stats[stat_name] += amount

/datum/round_stats/proc/calculate_stats()
	var/work_time = round( world.time/10 )*living_mob_list.len
	var/productivity = max(round(100*(1-(stats["break_time"]/work_time))),0) // Productivity is just percentage of time spent not AFK
	productivity = max(0,min(99.99, productivity - (stats["deaths"]*3 + stats["clones"]*2 + stats["bombs_exploded"]*5 + stats["vended"] + stats["people_slipped"]*2) + (stats["beepsky_beatings"]*2 + stats["blood_mopped"] + stats["spam_blocked"])))
	stats["productivity"] = productivity
	stats["cargo_profit"] = supply_controller.points * rand(900, 1100)

/datum/round_stats/proc/display()
	var/datum/nanoui/ui = null
	var/data[0]

	data["productivity_desc"] = "Crew Productivity: "
	data["productivity"] = "[stats["productivity"]]%"
	data["structural_desc"] = descriptions["damage_cost"]
	data["structural"] = stats["damage_cost"]
	data["deaths_desc"] = descriptions["deaths"]
	data["deaths"] = stats["deaths"]
	data["clones_desc"] = descriptions["clones"]
	data["clones"] = stats["clones"]

	var/list/chosen_stats = list("productivity", "deaths", "clones", "damage_cost") // stats that have already been chosen to be displays

	for( var/i = 0, i < 10, i++ )
		var/stat = pick( stats )
		if(!(stat in chosen_stats))
			chosen_stats.Add(stat)

			data["stat_[i]_desc"] = descriptions[stat]
			data["stat_[i]"] = round(stats[stat], 0.01)
			if(stat == "cargo_profit")
				data["stat_[i]"] = "$[data["stat_[i]"]]"
			if( units[stat] )
				data["stat_[i]_unit"] = units[stat]
			else
				data["stat_[i]_unit"] = ""
		else
			i--
	for(var/mob/M in player_list)
		if(M.client)
			ui = new(M, M, "main", "stats.tmpl", "End Round Stats", 500, 450)
			ui.set_initial_data(data)
			ui.open()

datum/round_stats/proc/call_stats()
	statistics.calculate_stats()
	statistics.save_stats()
	statistics.display()

datum/round_stats/proc/save_stats()
	if( !dbcon.IsConnected() )
		return 0

	var/gamemode = ""
	var/antags = ""
	if(ticker && ticker.mode)
		gamemode = ticker.mode.name
		antags = ""
		var/list/antag_list = list()
		var/list/seen_minds = list()
		antag_list.Add(ticker.mode.aliens)
		antag_list.Add(ticker.mode.borers)
		antag_list.Add(ticker.mode.changelings)
		antag_list.Add(ticker.mode.cult)
		antag_list.Add(ticker.mode.head_revolutionaries)
		antag_list.Add(ticker.mode.ninjas)
		antag_list.Add(ticker.mode.raiders)
		antag_list.Add(ticker.mode.revolutionaries)
		antag_list.Add(ticker.mode.syndicates)
		antag_list.Add(ticker.mode.traitors)
		antag_list.Add(ticker.mode.wizards)
		for(var/datum/mind/M in antag_list)
			if(!(M in seen_minds))
				seen_minds.Add(M)
				antags = antags + "[M.name] the [M.special_role], "

	var/ai_laws = ""
	for(var/mob/living/silicon/S in mob_list)
		if(S.laws.zeroth)
			ai_laws = ai_laws + "[S.laws.zeroth], "
		for (var/index = 1, index <= S.laws.ion.len, index++)
			ai_laws = ai_laws + "[S.laws.ion[index]], "

	// Due to the size of this query it's easier to debug when it's split up over multiple lines...
	var/q = "INSERT INTO round_stats ("
	q = q + "id,"
	q = q + "game_mode,"
	q = q + "start_time,"
	q = q + "duration,"
	q = q + "antags,"
	q = q + "ai_laws,"
	q = q + "productivity,"
	q = q + "deaths,"
	q = q + "clones,"
	q = q + "dispense_volume,"
	q = q + "bombs_exploded,"
	q = q + "vended,"
	q = q + "run_distance,"
	q = q + "blood_mopped,"
	q = q + "damage_cost,"
	q = q + "break_time,"
	q = q + "monkey_deaths,"
	q = q + "spam_blocked,"
	q = q + "people_slipped,"
	q = q + "doors_opened,"
	q = q + "guns_fired,"
	q = q + "beepsky_beatings,"
	q = q + "doors_welded,"
	q = q + "total_kwh,"
	q = q + "artifacts,"
	q = q + "cargo_profit,"
	q = q + "trash_vented,"
	q = q + "ai_follow"
	q = q + ") VALUES ("
	q = q + "null,"
	q = q + "'[gamemode]',"
	q = q + "Now(),"
	q = q + "[world.time/600],"
	q = q + "'[sanitizeSQL(antags)]',"
	q = q + "'[sanitizeSQL(ai_laws)]',"
	q = q + "[stats["productivity"]],"
	q = q + "[stats["deaths"]],"
	q = q + "[stats["clones"]],"
	q = q + "[stats["dispense_volume"]],"
	q = q + "[stats["bombs_exploded"]],"
	q = q + "[stats["vended"]],"
	q = q + "[stats["run_distance"]],"
	q = q + "[stats["blood_mopped"]],"
	q = q + "[stats["damage_cost"]],"
	q = q + "[stats["break_time"]],"
	q = q + "[stats["monkey_deaths"]],"
	q = q + "[stats["spam_blocked"]],"
	q = q + "[stats["people_slipped"]],"
	q = q + "[stats["doors_opened"]],"
	q = q + "[stats["guns_fired"]],"
	q = q + "[stats["beepsky_beatings"]],"
	q = q + "[stats["doors_welded"]],"
	q = q + "[stats["total_kwh"]],"
	q = q + "[stats["artifacts"]],"
	q = q + "[stats["cargo_profit"]],"
	q = q + "[stats["trash_vented"]],"
	q = q + "[stats["ai_follow"]])"
	var/DBQuery/query = dbcon.NewQuery(q)
	query.Execute()
