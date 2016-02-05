//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

/datum/preferences
	// our holder client
	var/client/client

	// non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	// Ckey join date
	var/joined_date = ""
	var/passed_date = 0			//So we don't have to keep aquiring joined_date

	// game-preferences
	var/OOC_color = "#010000"			//Whatever this is set to acts as 'reset' color and is thus unusable as an actual custom color

	// UI prefs
	var/UI_style = "Midnight"
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255

	// Preference toggleables
	var/toggles = TOGGLES_DEFAULT

	// Saved characters
	var/list/characters = list()
	var/datum/character/selected_character

	// Items tied to the account
	var/list/account_items = list()
