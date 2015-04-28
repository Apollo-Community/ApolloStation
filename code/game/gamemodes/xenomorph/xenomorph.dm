/datum/game_mode
	// this includes admin-appointed aliens and multialiens. Easy!
	var/list/datum/mind/aliens = list()

/datum/game_mode/xenomorph
	name = "xenomorph"
	config_tag = "xenomorph"
//	restricted_jobs = list("Cyborg", "AI")//They are part of the AI if he is alien so are they, they use to get double chances
//	protected_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "Head of Security", "Captain")//AI", Currently out of the list as malf does not work for shit
	required_players = 5
	required_enemies = 1
	recommended_enemies = 1

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/aliens_possible = 2 //hard limit on aliens if scaling is turned off
	var/const/alien_scaling_coeff = 15.0 //how much does the amount of players get divided by to determine aliens


/datum/game_mode/xenomorph/announce()

/datum/game_mode/xenomorph/pre_setup()

	config.aliens_allowed = 1
	/*if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs*/

	var/list/possible_aliens = get_players_for_role(BE_ALIEN)

	// stop setup if no possible aliums
	if(!possible_aliens.len)
		return 0

	var/num_aliens = 1

	if(config.traitor_scaling)
		num_aliens = max(1, round((num_players())/(alien_scaling_coeff)))
	else
		num_aliens = max(1, min(num_players(), aliens_possible))

	for(var/datum/mind/player in possible_aliens)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_aliens -= player

	for(var/j = 0, j < num_aliens, j++)
		if (!possible_aliens.len)
			break
		var/datum/mind/alien = pick(possible_aliens)
		aliens += alien
		alien.assigned_role = "MODE"
		alien.special_role = "alien"
		possible_aliens.Remove(alien)

	if(!aliens.len)
		return 0
	return 1


/datum/game_mode/xenomorph/post_setup()
	for(var/datum/mind/alien in aliens)
		if (!config.objectives_disabled)
			forge_alien_objectives(alien)
		spawn(rand(10,100))
			finalize_alien(alien)
			greet_alien(alien)
	modePlayer += aliens
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1


/datum/game_mode/proc/forge_alien_objectives(var/datum/mind/alien_mind)

	var/explanation = "The species must survive. Make sure at least one Xenomorph escapes on the shuttle to spread the species."

	alien_mind.current << "<B>Objective #1</B>: [explanation]"

	return


/datum/game_mode/proc/greet_alien(var/datum/mind/alien)
	alien.current << "<B><font size=3 color=red>You are an alien!</font></B>"
	show_objectives(alien)


/datum/game_mode/proc/finalize_alien(var/datum/mind/alien)
	var/mob/original = alien.current

	alien.current.loc = pick(xeno_spawn)
	var/mob/living/carbon/alien/larva/new_xeno = new(alien.current.loc)

	alien.transfer_to(new_xeno)

	del original
	return


/datum/game_mode/alien/declare_completion()
	..()
	return//aliens will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/alien/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	//for(var/datum/mind/alien_mind in aliens)
	//	for(var/datum/objective/objective in alien_mind.objectives)
	//		objective.check_completion()
	return 0


/datum/game_mode/proc/check_alien_survive()
	var/aliens_survived = 0

	for(var/datum/mind/alien_mind in aliens)
		if (alien_mind.current && alien_mind.current.stat!=2)
			var/area/A = get_area(alien_mind.current )
			if ( is_type_in_list(A, centcom_areas))
				aliens_survived++

	for(var/mob/new_player/player in player_list)
		if(player.status_flags & (XENO_HOST) || player.parent_type == "/mob/living/carbon/alien")
			var/area/A = get_area(player)
			if(is_type_in_list(A, centcom_areas))
				aliens_survived++

	if(aliens_survived >= 1)
		return 1
	else
		return 0

/datum/game_mode/proc/auto_declare_completion_alien()
	if(aliens.len)
		var/text = "<FONT size = 2><B>The aliens were:</B></FONT>"

		for(var/datum/mind/alien in aliens)
			text += print_player_full(alien)

		var/alienwin = check_alien_survive()

		if(alienwin)
			text += "<br><B>Objective #1</B>: The species must survive. Make sure at least one Xenomorph escapes on the shuttle to spread the species. <font color='green'><B>Success!</B></font>"
		else
			text += "<br><B>Objective #1</B>: The species must survive. Make sure at least one Xenomorph escapes on the shuttle to spread the species. <font color='red'>Fail.</font>"

		if(alienwin)
			text += "<br><font color='green'><B>The Xenomorphs were successful!</B></font>"
			feedback_add_details("alien_success","SUCCESS")
		else
			text += "<br><font color='red'><B>The Xenomorphs were failed!</B></font>"
			feedback_add_details("alien_success","FAIL")

		text += "<br>"

		world << text
	return 1


/datum/game_mode/proc/equip_alien(mob/living/carbon/human/alien_mob, var/safety = 0)
	return

