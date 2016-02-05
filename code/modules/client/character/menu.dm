/datum/character/proc/process_links( mob/user, list/href_list )
	if(!user)	return

	if(!istype(user, /mob/new_player))	return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forumurl)
			user << link(config.forumurl)
		else
			user << "<span class='danger'>The forum URL is not set in the server configuration.</span>"
			return

	if(href_list["preference"] == "disabilities_menu" )
		DisabilitiesMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "records_menu" )
		RecordsMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "records_menu" )
		RecordsMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] =="flavor_text_menu" )
		FlavorTextMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "job_menu")
		JobChoicesMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "antag_options_menu" )
		AntagOptionsMenuProcess( user, href_list )
		return 1

	if(href_list["preference"] == "edit_character" )
		EditCharacterMenuProcess( user, href_list )
		return 1

/*	else if(href_list["preference"] == "skills")
		if(href_list["cancel"])
			user << browse(null, "window=show_skills")
			ShowChoices(user)
		else if(href_list["skillinfo"])
			var/datum/skill/S = locate(href_list["skillinfo"])
			var/HTML = "<b>[S.name]</b><br>[S.desc]"
			user << browse(HTML, "window=\ref[user]skillinfo")
		else if(href_list["setskill"])
			var/datum/skill/S = locate(href_list["setskill"])
			var/value = text2num(href_list["newvalue"])
			skills[S.ID] = value
			CalculateSkillPoints()
			SetSkills(user)
		else if(href_list["preconfigured"])
			var/selected = input(user, "Select a skillset", "Skillset") as null|anything in SKILL_PRE
			if(!selected) return

			ZeroSkills(1)
			for(var/V in SKILL_PRE[selected])
				if(V == "field")
					skill_specialization = SKILL_PRE[selected]["field"]
					continue
				skills[V] = SKILL_PRE[selected][V]
			CalculateSkillPoints()

			SetSkills(user)
		else if(href_list["setspecialization"])
			skill_specialization = href_list["setspecialization"]
			CalculateSkillPoints()
			SetSkills(user)
		else
			SetSkills(user))
		return 1*/
	else if (href_list["preference"] == "loadout")

		if(href_list["task"] == "input")

			var/list/valid_gear_choices = list()

			for(var/gear_name in gear_datums)
				var/datum/gear/G = gear_datums[gear_name]
				if(G.whitelisted && !is_alien_whitelisted(user, G.whitelisted))
					continue
				if( istype( G, /datum/gear/account ))
					continue
				valid_gear_choices += gear_name

			var/choice = input(user, "Select gear to add: ") as null|anything in valid_gear_choices

			if(choice && gear_datums[choice])

				var/total_cost = 0

				if(isnull(gear) || !islist(gear)) gear = list()

				if(gear && gear.len)
					for(var/gear_name in gear)
						if(gear_datums[gear_name])
							var/datum/gear/G = gear_datums[gear_name]
							total_cost += G.cost

				var/datum/gear/C = gear_datums[choice]
				total_cost += C.cost
				if(C && total_cost <= MAX_GEAR_COST)
					gear += choice
					user << "<span class='notice'>Added \the '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>"
				else
					user << "<span class='warning'>Adding \the '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>"

		else if(href_list["task"] == "remove")
			var/i_remove = text2num(href_list["gear"])
			if(i_remove < 1 || i_remove > gear.len) return
			gear.Cut(i_remove, i_remove + 1)

		else if(href_list["task"] == "clear")
			gear.Cut()
	else if(href_list["preference"] == "acc_items")
		if( !account_items || !account_items.len )
			src << "There are no items tied to your account."
			return

		var/list/valid_gear_choices = list()

		for(var/gear_name in account_items)
			var/datum/gear/G = gear_datums[gear_name]
			if( !G )
				continue
			if( !G.account )
				continue
			valid_gear_choices += gear_name

		var/choice = input(user, "Select item to add: ") as null|anything in valid_gear_choices

		if( !choice )
			return

		if( choice in gear )
			user << "<span class='warning'>You already have this item selected.</span>"
			return

		if( !gear_datums[choice] )
			return

		if(isnull(gear) || !islist(gear))
			gear = list()

		gear += choice
		user << "<span class='notice'>Added \the '[choice]'.</span>"

	else if(href_list["preference"] == "pAI")
		paiController.recruitWindow(user, 0)
		return 1

	else if(href_list["preference"] == "records")
		RecordsMenuProcess( user, href_list )

	else if (href_list["preference"] == "antagoptions")
		if(text2num(href_list["active"]) == 0)
			SetAntagoptions(user)
			return
		if (href_list["antagtask"] == "uplinktype")
			if (uplinklocation == "PDA")
				uplinklocation = "Headset"
			else if(uplinklocation == "Headset")
				uplinklocation = "None"
			else
				uplinklocation = "PDA"
			SetAntagoptions(user)
		if (href_list["antagtask"] == "done")
			user << browse(null, "window=antagoptions")
			ShowChoices(user)
		return 1

	else if (href_list["preference"] == "loadout")

		if(href_list["task"] == "input")

			var/list/valid_gear_choices = list()

			for(var/gear_name in gear_datums)
				var/datum/gear/G = gear_datums[gear_name]

				if(( G.whitelisted && !is_alien_whitelisted( user, G.whitelisted )) || G.account )
					continue
				valid_gear_choices += gear_name

			var/choice = input(user, "Select gear to add: ") as null|anything in valid_gear_choices

			if(choice && gear_datums[choice])

				var/total_cost = 0

				if(isnull(gear) || !islist(gear)) gear = list()

				if(gear && gear.len)
					for(var/gear_name in gear)
						if(gear_datums[gear_name])
							var/datum/gear/G = gear_datums[gear_name]
							total_cost += G.cost

				var/datum/gear/C = gear_datums[choice]
				total_cost += C.cost
				if(C && total_cost <= MAX_GEAR_COST)
					gear += choice
					user << "<span class='notice'>Added [choice] for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>"
				else
					user << "<span class='alert'>That item will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>"

		else if(href_list["task"] == "remove")

			if(isnull(gear) || !islist(gear))
				gear = list()
			if(!gear.len)
				return

			var/choice = input(user, "Select gear to remove: ") as null|anything in gear
			if(!choice)
				return

			for(var/gear_name in gear)
				if(gear_name == choice)
					gear -= gear_name
					break

	switch(href_list["task"])
		if("change")
			if(href_list["preference"] == "species")
				// Actual whitelist checks are handled elsewhere, this is just for accessing the preview window.
				var/choice = input("Which species would you like to look at?") as null|anything in playable_species
				if(!choice) return
				species_preview = choice
				SetSpecies(user)

		if("random")
			switch(href_list["preference"])
				if("name")
					name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair_color")
					hair_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("hair_style")
					hair_style = random_hair_style(gender, species)
				if("facial")
					hair_face_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("hair_face_style")
					hair_face_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = rand(1,underwear_m.len)
					ShowChoices(user)
				if("undershirt")
					undershirt = rand(1,undershirt_t.len)
					ShowChoices(user)
				if("eye_color")
					eye_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("skin_tone")
					skin_tone = random_skin_tone()
				if("skin_color")
					skin_color = rgb( rand( 0, 255 ), rand( 0, 255 ), rand( 0, 255 ))
				if("bag")
					backpack = rand(1,4)
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE

				if("disabilities")				//please note: current code only allows nearsightedness as a disability
					disabilities = !disabilities//if you want to add actual disabilities, code that selects them should be here

/*				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Orange"
						if("Orange")
							UI_style = "old"
						if("old")
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

				if("job_antag")
					var/num = text2num(href_list["num"])
					job_antag ^= (1<<num)

				if("name")
					be_random_name = !be_random_name

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
					else
						user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("save")
					savePreferences()
					save_character()

				if("reset")
					load_preferences()
					load_character()

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					load_character(text2num(href_list["num"]))
					close_load_dialog(user)*/

	ShowChoices(user)
	return 1