//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTEARS
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"]."
	prefs.savePreferences()
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTSIGHT
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"]."
	prefs.savePreferences()
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = ".Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles ^= CHAT_GHOSTRADIO
	src << "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"]."
	prefs.savePreferences()
	feedback_add_details("admin_verb","TGR")

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers"
	if(!holder) return
	prefs.toggles ^= CHAT_RADIO
	prefs.savePreferences()
	usr << "You will [(prefs.toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers"
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.toggles ^= CHAT_DEAD
	prefs.savePreferences()

	if(src.holder)
		src << "You will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat."
	else
		src << "As a ghost, you will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat."

	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.toggles ^= CHAT_PRAYER
	prefs.savePreferences()
	src << "You will [(prefs.toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat."
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.toggles ^= SOUND_LOBBY
	prefs.savePreferences()
	if(prefs.toggles & SOUND_LOBBY)
		src << "You will now hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			playtitlemusic()
	else
		src << "You will no longer hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz
	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins"
	prefs.toggles ^= SOUND_MIDI
	prefs.savePreferences()
	if(prefs.toggles & SOUND_MIDI)
		src << "You will now hear any sounds uploaded by admins."
	else
		src << "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled."
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = 777)
		break_sound.priority = 250
		src << break_sound	//breaks the client's sound output on channel 777
	feedback_add_details("admin_verb","TMidi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles ^= CHAT_OOC
	prefs.savePreferences()
	src << "You will [(prefs.toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel."
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/sound_notification()
	set name = "Toggle OOC Sounds"
	set category = "Preferences"
	set desc = "Toggles the OOC notificaiton sounds"
	prefs.toggles ^= SOUND_NOTIFICATIONS
	prefs.savePreferences()
	src << "You will [(prefs.toggles & SOUND_NOTIFICATIONS) ? "now" : "no longer"] hear notifications from the OOC channel."
	feedback_add_details("admin_verb","SOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_looc()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Toggles seeing Local OutOfCharacter chat"
	prefs.toggles ^= CHAT_LOOC
	prefs.savePreferences()

	src << "You will [(prefs.toggles & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel."
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/toggle_chattags()
	set name = "Show/Hide Chat Tags"
	set category = "Preferences"
	set desc = "Toggles seeing chat tags/icons"
	prefs.toggles ^= CHAT_NOICONS
	prefs.savePreferences()

	src << "You will [!(prefs.toggles & CHAT_NOICONS) ? "now" : "no longer"] see chat tag icons."
	feedback_add_details("admin_verb","TCTAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.toggles ^= SOUND_AMBIENCE
	ambience_playing = 0
	prefs.savePreferences()
	if(prefs.toggles & SOUND_AMBIENCE)
		src << "You will now hear ambient sounds."
	else
		src << "You will no longer hear ambient sounds."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//be special
/client/verb/toggle_be_special(role in be_special_flags)
	set name = "Toggle SpecialRole Candidacy"
	set category = "Preferences"
	set desc = "Toggles which special roles you would like to be a candidate for, during events."
	var/role_flag = be_special_flags[role]
	if(!role_flag)	return
	prefs.selected_character.job_antag ^= role_flag
	prefs.savePreferences()
	src << "You will [(prefs.beSpecial() & role_flag) ? "now" : "no longer"] be considered for [role] events (where possible)."
	feedback_add_details("admin_verb","TBeSpecial") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences"
	set desc = "Configure your user interface"

	if(!ishuman(usr))
		usr << "This only for human"
		return

	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") in list("White", "Midnight", "Orange", "old")
	if(!UI_style_new) return

	var/UI_style_alpha_new = input(usr, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
	if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = input(usr, "Choose your UI color, dark colors are not recommended!") as color|null
	if(!UI_style_color_new) return

	//update UI
	var/list/icons = usr.hud_used.adding + usr.hud_used.other +usr.hud_used.hotkeybuttons
	icons.Add(usr.zone_sel)

	for(var/obj/screen/I in icons)
		if(I.name in list(I_HELP, "harm", I_DISARM, I_GRAB)) continue
		I.icon = ui_style2icon(UI_style_new)
		I.color = UI_style_color_new
		I.alpha = UI_style_alpha_new



	if(alert("Like it? Save changes?",,"Yes", "No") == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_style_alpha_new
		prefs.UI_style_color = UI_style_color_new
		prefs.savePreferences()
		usr << "UI was saved"