#define STATION_EROSION 60 // Mostly an arbitrary number, the number of small explosions to create
#define BARRICADE_LEVEL 40 // Percentage of areas barricaded

/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/broodswarm = list()

/datum/game_mode/broodswarm
	name = "Broodswarm"
	config_tag = "broodswarm"
	required_players = 10
	required_enemies = 1
	recommended_enemies = 1

	var/const/waittime_l = 50 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 300 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/broodswarm/announce()

/datum/game_mode/broodswarm/pre_setup()
	spawn(0)
		station_erosion( 60 )

	spawn(1)
		populate_random_items()

	spawn(3)
		populate_barricades( 40 )

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_broodswarm = get_players_for_role(BE_BROODSWARM)

	// stop setup if no possible traitors
	if(!possible_broodswarm.len)
		return 0

	var/num_brood = 1

	for(var/datum/mind/player in possible_broodswarm)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_broodswarm -= player

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/brood = pick(possible_broodswarm)
		broodswarm += brood
		brood.special_role = "traitor"
		possible_broodswarm.Remove(brood)

	if(!broodswarm.len)
		return 0
	return 1


/datum/game_mode/broodswarm/post_setup()


/datum/game_mode/proc/greet_broodmother(var/datum/mind/broodmother)
	broodmother.current << "<B><font size=3 color=red>You are the Broodmother.</font></B>"
	show_objectives(broodmother)


/datum/game_mode/broodswarm/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.
