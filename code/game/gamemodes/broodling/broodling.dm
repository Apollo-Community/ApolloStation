/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/broodling
	name = "broodling"
	config_tag = "broodling"
	required_players = 10
	required_enemies = 1
	recommended_enemies = 1

	var/const/waittime_l = 50 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 300 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/broodling/announce()

/datum/game_mode/broodling/pre_setup()

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
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		traitor.special_role = "traitor"
		possible_traitors.Remove(traitor)

	if(!traitors.len)
		return 0
	return 1


/datum/game_mode/broodling/post_setup()


/datum/game_mode/proc/greet_broodmother(var/datum/mind/broodmother)
	broodmother.current << "<B><font size=3 color=red>You are the Broodmother.</font></B>"
	show_objectives(broodmother)


/datum/game_mode/broodling/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.
