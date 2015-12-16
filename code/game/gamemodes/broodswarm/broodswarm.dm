#define STATION_EROSION 60 // Mostly an arbitrary number, the number of small explosions to create
#define BARRICADE_LEVEL 40 // Percentage of areas barricaded

/datum/game_mode
	var/list/datum/mind/broodswarm = list()

/datum/game_mode/broodswarm
	name = "broodswarm"
	config_tag = "broodswarm"
	required_players = 1
	required_enemies = 1
	recommended_enemies = 1

	restricted_jobs = list()
	protected_jobs = list()

	var/const/waittime_l = 50 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 300 //upper bound on time before intercept arrives (in tenths of seconds)

	var/datum/mind/broodmother

/datum/game_mode/broodswarm/announce()
	world << "<span class='warning'>The station was brutalized by meteor impacts multiple hours ago. Communication with Central Command has been knocked out, and </span>"

/datum/game_mode/broodswarm/pre_setup()
	world << "pre_setup() called"

	station_erosion( 60 )

	populate_random_items()

	populate_barricades( 40 )

	create_broodmother()

	return 1

/datum/game_mode/broodswarm/post_setup()
	world << "post_setup() called"
	greet_broodmother()

	return 1

/datum/game_mode/broodswarm/proc/create_broodmother()
	var/list/possible_broodswarm = get_players_for_role( BE_BROODSWARM )

	var/datum/mind/brood = pick(possible_broodswarm)

	world << "[brood.name] chosen as the broodmother!"

	if( !brood )
		world << "No brood available!"
		return 0

	broodswarm += brood
	broodmother = brood
	var/mob/living/carbon/human/H = brood.current
	world << "[H] chosen as the broodmother!"
	H.set_species("Broodmother")
	H.loc = pick( blobstart )
	possible_broodswarm.Remove(brood)

	if(!broodswarm.len)
		world << "No viable broodswarm"
		return 0

/datum/game_mode/broodswarm/proc/greet_broodmother()
	broodmother.current << "<B><font size=3 color=red>You are the Broodmother.</font></B>"
	show_objectives(broodmother)

/datum/game_mode/broodswarm/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.
