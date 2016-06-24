/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/buildmode		= 0
	var/angry = 0 // toggles madmin
	var/donator = 0			//Makes mob.stat() much faster.

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/time_died_as_rodent = null //when the client last died as a mouse

	var/adminhelped = 0

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = CONTROL_FREAK_ALL

	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0


		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "Requires database"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	// Special character tokens
	var/list/character_tokens = list()

	// Antagonist weights
	var/list/antag_weights = list(
		"no_antag" = 0,
		"static" = 0
	)

	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	var/afk = 0
	var/afk_start_time = 0 // Used to keep track of time they started being AFK

	var/session_start_time = 0 // When did our session begin?
	var/total_afk_time = 0 // How low have we been AFK this session?

	////////////
	//PARALLAX//
	////////////
	var/updating_parallax = 0
	var/list/parallax = list()
	var/list/parallax_offset = list()
	var/turf/previous_turf = null
	var/obj/screen/plane_master/parallax_master/parallax_master = null
	var/obj/screen/plane_master/parallax_dustmaster/parallax_dustmaster = null
	var/obj/screen/plane_master/parallax_spacemaster/parallax_spacemaster = null
	var/obj/screen/parallax_canvas/parallax_canvas = null
	var/last_parallax_shift
