/datum/round_stats
	var/list/deaths = list()

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
								  "banned" = "People Fired: ",
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
						   "banned" = 0,
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

datum/round_stats/proc/report_death(var/mob/living/H)
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/area/placeofdeath = get_area(H)
	var/podname = placeofdeath ? placeofdeath.name : "Unknown area"

	var/sqlname = sanitizeSQL(H.real_name)
	var/sqlkey = sanitizeSQL(H.key)
	var/sqlpod = sanitizeSQL(podname)
	var/sqlspecial = sanitizeSQL(H.mind.antagonist)
	var/sqljob = sanitizeSQL(H.mind.assigned_role)
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = sanitizeSQL(H.lastattacker:real_name)
		lakey = sanitizeSQL(H.lastattacker:key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"

	deaths.Add("'[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.getBruteLoss()], [H.getFireLoss()], [H.brainloss], [H.getOxyLoss()], '[coord]'")

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

	var/gamemode = ticker.mode.name

	// Due to the size of this query it's easier to debug when it's split up over multiple lines...
	var/q = "INSERT INTO round_stats ("
	q = q + "id,"
	q = q + "game_mode,"
	q = q + "end_time,"
	q = q + "duration,"
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
	q = q + "ai_follow,"
	q = q + "banned"
	q = q + ") VALUES ("
	q = q + "null,"
	q = q + "'[gamemode]',"
	q = q + "Now(),"
	q = q + "[world.time/600],"
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
	q = q + "[stats["ai_follow"]],"
	q = q + "[stats["banned"]])"
	var/DBQuery/query = dbcon.NewQuery(q)
	query.Execute()

	if(query.RowsAffected() != 1)
		return 0

	// Try to grab the round id for the newly inserted row
	query.Execute("SELECT id FROM round_stats ORDER BY id DESC LIMIT 1")
	if(query.RowCount() != 1)
		return 0
	query.NextRow()
	var/data = query.GetRowData()
	var/round_id = data["id"]

	var/list/antags = list()
	var/list/antag_list = list()
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
		if(!(M in antags))
			antags.Add(M)
			var/win = 1
			for(var/datum/objective/objective in M.objectives)
				if(!objective.check_completion())
					win = 0
			query.Execute("INSERT INTO round_antags (id, round_id, ckey, name, job, role, success) VALUES(null, [round_id], '[sanitizeSQL(M.key)]', '[sanitizeSQL(M.name)]', '[sanitizeSQL(M.assigned_role)]', '[sanitizeSQL(M.antagonist)]', [win])")

	for(var/mob/living/silicon/S in mob_list)
		if(S.laws.zeroth)
			query.Execute("INSERT INTO round_ai_laws (id, round_id, law) VALUES(null, [round_id], '[sanitizeSQL(S.laws.zeroth)]')")
		for (var/index = 1, index <= S.laws.ion.len, index++)
			query.Execute("INSERT INTO round_ai_laws (id, round_id, law) VALUES(null, [round_id], '[sanitizeSQL(S.laws.ion[index])]')")

	for(var/text in deaths)
		query.Execute("INSERT INTO deaths (id, round_id, name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES (null, [round_id], [text])")
