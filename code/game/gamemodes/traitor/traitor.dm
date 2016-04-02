/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg", "AI")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "Head of Security", "Captain")//AI", Currently out of the list as malf does not work for shit
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine traitors

/datum/game_mode/traitor/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(BE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/datum/mind/player in possible_traitors)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_traitors -= player

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)

		traitors += traitor
		traitor.antagonist = new /datum/antagonist/traitor(traitor)
		possible_traitors.Remove(traitor)

	if(!traitors.len)
		return 0
	return 1

/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		if(istype(traitor.current, /mob/living/silicon/ai))
			traitor.antagonist.faction = /datum/faction/syndicate/self
		traitor.antagonist.setup()
	modePlayer += traitors

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<font size=2><B>The syndicate factions with active agents were:</B></font><br>"
		for(var/datum/faction/syndicate/S in faction_controller.factions)
			if(S.members.len > 0)
				text += "<B>\The [S.name]</B>, with [S.members.len] agent[S.members.len > 1 ? "s" : ""] present.<br>"
				text += "The [S.name] agents were:<br>"
				for(var/datum/mind/M in S.members)
					text += print_player_full(M)
					text += "<br>"
					text += "[M.name] had to complete at least [M.antagonist.obligatory_contracts] contract. They took on the following contracts:<br>"
					for(var/datum/contract/C in M.antagonist.completed_contracts)
						text += "[C.informal_name ? C.informal_name : C.title]. <font color='green'><B>Completed!</B></font><br>"
						feedback_add_details("traitor_contract","[C.type]|SUCCESS")
					for(var/datum/contract/C in M.antagonist.failed_contracts)
						text += "[C.informal_name ? C.informal_name : C.title]. <font color='red'>Fail</font><br>"
						feedback_add_details("traitor_contract","[C.type]|SUCCESS")

					if(M.antagonist.completed_contracts.len > M.antagonist.obligatory_contracts)
						text += "<br><font color='green'><B>The [lowertext(M.antagonist.name)] was successful!</B></font>"
						feedback_add_details("traitor_success","SUCCESS")
					else
						text += "<br><font color='red'><B>The [lowertext(M.antagonist.name)] has failed!</B></font>"
						feedback_add_details("traitor_success","FAIL")
				text += "<br>"
		text += "<br>"

		world << text
	return 1
