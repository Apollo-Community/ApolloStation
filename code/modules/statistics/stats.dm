/datum/round_stats
	// Totals
	var/deaths = 0
	var/clones = 0
	var/dispense_volume = 0 // Total volume of chemicals dispensed by chem dispensers
	var/bombs_exploded = 0 // Total number of bombs exploded
	var/vended = 0 // Total number of items vended from vending machines
	var/run_distance = 0 // Total distance run in meters
	var/blood_mopped = 0 // Total volume of blood mopped up in liters
	var/damage_cost = 0 // Cost of all station damages
	var/break_time = 0 // Total time spent AFK
	var/monkey_deaths = 0 // Total number of monkeys killed
	var/spam_blocked = 0 // PDA messages blocked by spam filter
	var/people_slipped = 0 // Total number of times people have slipped
	var/doors_opened = 0 // Total number of times doors have been opened
	var/guns_fired = 0 // Total number of times any type of gun has been fired
	var/beepsky_beatings = 0 // Total number of times beepsky arrested someone
	var/doors_welded = 0 // Total number of doors welded

	var/total_kwh = 0 // Total kilowatt/hours produced by engineering
	var/artifacts = 0 // Total number of artifacts dug up
	var/cargo_profit = 0 // Profit made from cargobay
	var/arrests = 0 // Total number of arrests

/datum/round_stats/proc/display()
	var/work_time = round( world.time/10 )*living_mob_list.len
	var/productivity = max(round(100*(1-(break_time/work_time))),0) // Productivity is just percentage of time spent not AFK
	productivity = max(0,min(99.99, productivity - (deaths*3 + clones*2 + bombs_exploded*5 + vended + people_slipped*2) + (beepsky_beatings*2 + blood_mopped + spam_blocked)))

	var/datum/nanoui/ui = null
	var/data[0]

	data["structural"] = damage_cost
	data["productivity"] = productivity
	data["doors"] = doors_opened - 30
	data["deaths"] = deaths - 1
	data["ran"] = round((run_distance/1000)/42.00,0.01)

	data["clone"] = clones
	data["bombs"] = bombs_exploded
	data["junk"] = vended
	data["spam"] = spam_blocked
	data["mkilled"] = monkey_deaths
	data["chems"] = dispense_volume/100
	data["blood"] = blood_mopped
	data["slips"] = people_slipped
	data["shots"] = guns_fired
	data["beepsky"] = beepsky_beatings

	for(var/client/C in clients)
		ui = nanomanager.try_update_ui(usr, usr, "main", ui, data, 1)
		if (!ui)
			ui = new(usr, usr, "main", "stats.tmpl", "End Round Stats", 500, 450)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

datum/round_stats/proc/call_stats()
	statistics.display()