/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("Cyborg", "AI")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "Head of Security", "Captain")//AI", Currently out of the list as malf does not work for shit
	required_players = 3
	required_players_secret = 10
	required_enemies = 2
	recommended_enemies = 3

/datum/game_mode/traitor/changeling/announce()

/datum/game_mode/traitor/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	if(possible_changelings.len>0)
		var/datum/mind/changeling = pick(possible_changelings)
		//possible_changelings-=changeling
		changelings += changeling
		modePlayer += changelings
		return ..()
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		if(!config.objectives_disabled)
			forge_changeling_objectives(changeling)
		greet_changeling(changeling)
		changeling.character.temporary = 1 // Makes them non-canon
	..()
	return