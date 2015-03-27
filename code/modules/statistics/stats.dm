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
	var/productivity = 0
	var/work_time = round( world.time/10 )*living_mob_list.len
	productivity = round(100*(1-(break_time/work_time))) // Productivity is just percentage of time spent not AFK

	var/data = "<hr><center><b><h2>Round Statistics</h2></b></center><hr>"
	data += "<h3>TOTALS</h3>"
	data += "Structural Damages: <b>\red $[damage_cost]</b><br>"
	data += "Crew productivity: <b>[productivity]%</b><br>"
	data += "Deaths: <b>[deaths] unfortunates</b><br>"
	data += "Time spent waiting for doors to open: <b>[doors_opened*0.4] seconds</b><br>"
	data += "Number of reconstituted crew: <b>[clones] clones</b><br>"
	data += "Bombs exploded: <b>[bombs_exploded] accidents waiting to happen</b><br>"
	data += "Junk food vended: <b>[vended]</b><br>"
	data += "Crew running distance: <b>[(run_distance/1000)/42.00] marathons</b><br>"
	data += "Spam blocked: <b>[spam_blocked] messages returned to sender</b><br>"
	data += "Monkeys inhumanely slain: <b>[monkey_deaths]</b><br>"
	data += "Chemicals dispensed: <b>[dispense_volume/100] L</b><br>"
	data += "Blood mopped: <b>[blood_mopped] L of blood</b><br>"
	data += "Slippery floor signs ignored: <b>[people_slipped] slippings</b><br>"
	data += "Weapons fired: <b>[guns_fired] 'warning' shots</b><br>"
	data += "Beepsky beatings: <b>[people_slipped] criminal scums detained</b><br>"

	world << data