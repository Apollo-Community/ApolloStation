/datum/character/proc/EditCharacterMenu(mob/user)
	if(!istype( user ) || !user.client)	return

	var/menu_name = "edit_character"

	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")

	var/dat = "<html><body><center>"

	dat += "IMPLEMENT LOADING AND SAVING KWASK"

	dat += "</center><hr><table><tr><td width='340px' height='320px'>"

	dat += "<b>Name:</b> "
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=name'><b>[name]</b></a><br>"
	dat += "(<a href='byond://?src=\ref[user];character=[menu_name];task=name_random'>Random Name</A>) "
	dat += "<br>"

	dat += "<b>Gender:</b> <a href='byond://?src=\ref[user];character=[menu_name];task=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
	dat += "<b>Age:</b> <a href='byond://?src=\ref[user];character=[menu_name];task=age'>[age]</a><br>"
	dat += "<b>Spawn Point</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=spawnpoint'>[spawnpoint]</a>"
	dat += "<br>"

	dat += "<br><b>Custom Loadout:</b> "
	var/total_cost = 0

	if(!islist(gear)) gear = list()

	if(gear && gear.len)
		dat += "<br>"
		for(var/i = 1; i <= gear.len; i++)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G)
				if( !G.account )
					total_cost += G.cost
				dat += "[gear[i]]"
				if( !G.account )
					dat += " ([G.cost] points) "
				else
					dat += " (Account Item) "
				dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=loadout_remove;gear=[i]'>\[remove\]</a><br>"

		dat += "<b>Used:</b> [total_cost] points."
	else
		dat += "none."

	if(total_cost < MAX_GEAR_COST)
		dat += " <a href='byond://?src=\ref[user];character=[menu_name];task=loadout_add'>\[add\]</a>"
		if(gear && gear.len)
			dat += " <a href='byond://?src=\ref[user];character=[menu_name];task=loadout_clear'>\[clear\]</a>"
	dat += "<br>"

	dat += "\t<a href='byond://?src=\ref[user];character=[menu_name];task=acc_items'><b>Account Items</b></a><br>"

	dat += "<br><br><b>Occupation Choices</b><br>"
	dat += "\t<a href='byond://?src=\ref[user];character=[menu_name];task=job_menu'><b>Set Preferences</b></a><br>"

	dat += "<br><table><tr><td><b>Body</b> "
	dat += "(<a href='byond://?src=\ref[user];character=[menu_name];task=all_random'>Randomize</A>)"
	dat += "<br>"
	dat += "Species: <a href='byond://?src=\ref[user];character=[menu_name];task=species_menu'>[species]</a><br>"
	dat += "Secondary Language:<br><a href='byond://?src=\ref[user];character=[menu_name];task=language'>[additional_language]</a><br>"
	dat += "Blood Type: [blood_type]<br>"
	dat += "Skin Tone: <a href='byond://?src=\ref[user];character=[menu_name];task=skin_tone'>[-skin_tone + 35]/220<br></a>"
	dat += "Needs Glasses: <a href='byond://?src=\ref[user];character=[menu_name];task=disabilities'><b>[disabilities == 0 ? "No" : "Yes"]</b></a><br>"
	dat += "Limbs: <a href='byond://?src=\ref[user];character=[menu_name];task=limbs_adjust'>Adjust</a><br>"
	dat += "Internal Organs: <a href='byond://?src=\ref[user];character=[menu_name];task=organs_adjust'>Adjust</a><br>"

	//display limbs below
	var/ind = 0
	for(var/name in organ_data)
		//world << "[ind] \ [organ_data.len]"
		var/status = organ_data[name]
		var/organ_name = null
		switch(name)
			if("l_arm")
				organ_name = "left arm"
			if("r_arm")
				organ_name = "right arm"
			if("l_leg")
				organ_name = "left leg"
			if("r_leg")
				organ_name = "right leg"
			if("l_foot")
				organ_name = "left foot"
			if("r_foot")
				organ_name = "right foot"
			if("l_hand")
				organ_name = "left hand"
			if("r_hand")
				organ_name = "right hand"
			if("heart")
				organ_name = "heart"
			if("eyes")
				organ_name = "eyes"

		if(status == "cyborg")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tMechanical [organ_name] prothesis"
		else if(status == "amputated")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tAmputated [organ_name]"
		else if(status == "mechanical")
			++ind
			if(ind > 1)
				dat += ", "
			dat += "\tMechanical [organ_name]"
		else if(status == "assisted")
			++ind
			if(ind > 1)
				dat += ", "
			switch(organ_name)
				if("heart")
					dat += "\tPacemaker-assisted [organ_name]"
				if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
					dat += "\tSurgically altered [organ_name]"
				if("eyes")
					dat += "\tRetinal overlayed [organ_name]"
				else
					dat += "\tMechanically assisted [organ_name]"
	if(!ind)
		dat += "\[...\]<br><br>"
	else
		dat += "<br><br>"

	if(gender == MALE)
		dat += "Underwear: <a href='byond://?src=\ref[user];character=[menu_name];task=underwear'><b>[underwear_m[underwear]]</b></a><br>"
	else
		dat += "Underwear: <a href='byond://?src=\ref[user];character=[menu_name];task=underwear'><b>[underwear_f[underwear]]</b></a><br>"

	dat += "Undershirt: <a href='byond://?src=\ref[user];character=[menu_name];task=undershirt'><b>[undershirt_t[undershirt]]</b></a><br>"

	dat += "Backpack Type:<br><a href='byond://?src=\ref[user];character=[menu_name];task=backpack'><b>[backpacklist[backpack]]</b></a><br>"

	dat += "Nanotrasen Relation:<br><a href='byond://?src=\ref[user];character=[menu_name];task=nt_relation'><b>[nanotrasen_relation]</b></a><br>"

	dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>"

	dat += "</td><td width='300px' height='300px'>"

	if(jobban_isbanned(user, "Records"))
		dat += "<b>You are banned from using character records.</b><br>"
	else
		dat += "<b><a href='byond://?src=\ref[user];character=[menu_name];task=records_menu'>Character Records</a></b><br>"

	dat += "<b><a href='byond://?src=\ref[user];character=[menu_name];task=antag_options_menu'>Set Antag Options</b></a><br>"
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=flavor_text_menu'><b>Set Flavor Text</b></a><br>"

	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=pAI'><b>pAI Configuration</b></a><br>"
	dat += "<br>"

	dat += "<br><b>Hair</b><br>"
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=hair_color'>Change Color</a> <font face='fixedsys' size='3' color='[hair_color]'><table style='display:inline;' bgcolor='[hair_color]'><tr><td>__</td></tr></table></font> "
	dat += " Style: <a href='byond://?src=\ref[user];character=[menu_name];task=hair_style'>[hair_style]</a><br>"

	dat += "<br><b>Facial</b><br>"
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=hair_face_color'>Change Color</a> <font face='fixedsys' size='3' color='[hair_face_color]'><table  style='display:inline;' bgcolor='[hair_face_color]'><tr><td>__</td></tr></table></font> "
	dat += " Style: <a href='byond://?src=\ref[user];character=[menu_name];task=hair_face_style'>[hair_face_style]</a><br>"

	dat += "<br><b>Eyes</b><br>"
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=eye_color'>Change Color</a> <font face='fixedsys' size='3' color='[eye_color]'><table  style='display:inline;' bgcolor='[eye_color]'><tr><td>__</td></tr></table></font><br>"

	dat += "<br><b>Body Color</b><br>"
	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=skin_color'>Change Color</a> <font face='fixedsys' size='3' color='[skin_color]'><table style='display:inline;' bgcolor='[skin_color]'><tr><td>__</td></tr></table></font>"

	dat += "<br><br><b>Background Information</b><br>"
	dat += "<b>Home system</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=home_system'>[home_system]</a><br/>"
	dat += "<b>Citizenship</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=citizenship'>[citizenship]</a><br/>"
	dat += "<b>Faction</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=faction'>[faction]</a><br/>"
	dat += "<b>Religion</b>: <a href='byond://?src=\ref[user];character=[menu_name];task=religion'>[religion]</a><br/>"

	dat += "<br><br>"

	if(jobban_isbanned(user, "Syndicate"))
		dat += "<b>You are banned from antagonist roles.</b>"
		src.job_antag = 0
	else
		var/n = 0
		for (var/i in special_roles)
			if(special_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i) || (i == "positronic brain" && jobban_isbanned(user, "AI") && jobban_isbanned(user, "Cyborg")) || (i == "pAI candidate" && jobban_isbanned(user, "pAI")))
					dat += "<b>Be [i]:<b> <font color=red><b> \[BANNED]</b></font><br>"
				else
					dat += "<b>Be [i]:</b> <a href='byond://?src=\ref[user];character=[menu_name];task=job_antag;num=[n]'><b>[src.job_antag&(1<<n) ? "Yes" : "No"]</b></a><br>"
			n++
	dat += "</td></tr></table><hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=save'>Save Setup</a> - "

	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=reset'>Reset Changes</a> - "

	dat += "<a href='byond://?src=\ref[user];character=[menu_name];task=close'>Close</a>"
	dat += "</center></body></html>"

	user << browse(dat, "window=[menu_name];size=560x736")
	winshow( user, "edit_character", 1)

/datum/character/proc/EditCharacterMenuDisable( mob/user )
	winshow( user, "edit_character", 0)

/datum/character/proc/EditCharacterMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if("name")
			var/raw_name = input(user, "Choose your character's name:", "Character Preference")  as text|null
			if (!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
				var/new_name = sanitizeName(raw_name)
				if(new_name)
					name = new_name
				else
					user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

		if("age")
			var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
			if(new_age)
				age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

		if("language")
			var/languages_available
			var/list/new_languages = list("None")
			var/datum/species/S = all_species[species]

			if(config.usealienwhitelist)
				for(var/L in all_languages)
					var/datum/language/lang = all_languages[L]
					if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))||(S && (L in S.secondary_langs))))
						new_languages += lang

						languages_available = 1

				if(!(languages_available))
					alert(user, "There are not currently any available secondary languages.")
			else
				for(var/L in all_languages)
					var/datum/language/lang = all_languages[L]
					if(!(lang.flags & RESTRICTED))
						new_languages += lang.name

			additional_language = input("Please select a secondary language", "Character Generation", null) in new_languages

		if("hair_color")
			if(species == "Human" || species == "Unathi" || species == "Tajara" || species == "Skrell" || species == "Wryn")
				var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference", hair_color ) as color|null
				if( new_hair )
					hair_color = new_hair

		if("hair_style")
			var/list/valid_hairstyles = list()
			for(var/hairstyle in hair_styles_list)
				var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
				if( !(species in S.species_allowed))
					continue

				valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

			var/new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
			if(new_hair_style)
				hair_style = new_hair_style

		if("hair_face_color")
			var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", hair_face_color ) as color|null
			if(new_facial)
				hair_face_color = new_facial

		if("hair_face_style")
			var/list/valid_facialhairstyles = list()
			for(var/facialhairstyle in facial_hair_styles_list)
				var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
				if(gender == MALE && S.gender == FEMALE)
					continue
				if(gender == FEMALE && S.gender == MALE)
					continue
				if( !(species in S.species_allowed))
					continue

				valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

			var/new_hair_face_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
			if(new_hair_face_style)
				hair_face_style = new_hair_face_style

		if("underwear")
			var/list/underwear_options
			if(gender == MALE)
				underwear_options = underwear_m
			else
				underwear_options = underwear_f

			var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
			if(new_underwear)
				underwear = underwear_options.Find(new_underwear)

		if("undershirt")
			var/list/undershirt_options
			undershirt_options = undershirt_t

			var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_options
			if (new_undershirt)
				undershirt = undershirt_options.Find(new_undershirt)

		if("eye_color")
			var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", eye_color ) as color|null
			if(new_eyes)
				eye_color = new_eyes

		if("skin_tone")
			if(species != "Human")
				return
			var/new_skin_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
			if(new_skin_tone)
				skin_tone = 35 - max(min( round(new_skin_tone), 220),1)

		if("skin_color")
			if(species == "Unathi" || species == "Tajara" || species == "Skrell" || species == "Wryn")
				var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", skin_color ) as color|null
				if(new_skin)
					skin_color = new_skin

		if("backpack")
			var/new_backpack = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backpacklist
			if(new_backpack)
				backpack = backpacklist.Find(new_backpack)

		if("nt_relation")
			var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
			if(new_relation)
				nanotrasen_relation = new_relation

		if("disabilities")
			return
			/*if(text2num(href_list["disabilities"]) >= -1)
				if(text2num(href_list["disabilities"]) >= 0)
					disabilities ^= (1<<text2num(href_list["disabilities"])) //MAGIC
				SetDisabilities(user)
				return
			else
				user << browse(null, "window=disabil")*/

		if("limbs_adjust")
			var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
			if(!limb_name) return

			var/limb = null
			var/second_limb = null // if you try to change the arm, the hand should also change
			var/third_limb = null  // if you try to unchange the hand, the arm should also change
			switch(limb_name)
				if("Left Leg")
					limb = "l_leg"
					second_limb = "l_foot"
				if("Right Leg")
					limb = "r_leg"
					second_limb = "r_foot"
				if("Left Arm")
					limb = "l_arm"
					second_limb = "l_hand"
				if("Right Arm")
					limb = "r_arm"
					second_limb = "r_hand"
				if("Left Foot")
					limb = "l_foot"
					third_limb = "l_leg"
				if("Right Foot")
					limb = "r_foot"
					third_limb = "r_leg"
				if("Left Hand")
					limb = "l_hand"
					third_limb = "l_arm"
				if("Right Hand")
					limb = "r_hand"
					third_limb = "r_arm"

			var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Amputated","Prothesis")
			if(!new_state) return

			switch(new_state)
				if("Normal")
					organ_data[limb] = null
					if(third_limb)
						organ_data[third_limb] = null
				if("Amputated")
					organ_data[limb] = "amputated"
					if(second_limb)
						organ_data[second_limb] = "amputated"
				if("Prothesis")
					organ_data[limb] = "cyborg"
					if(second_limb)
						organ_data[second_limb] = "cyborg"
					if(third_limb && organ_data[third_limb] == "amputated")
						organ_data[third_limb] = null
		if("organs_adjust")
			var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
			if(!organ_name) return

			var/organ = null
			switch(organ_name)
				if("Heart")
					organ = "heart"
				if("Eyes")
					organ = "eyes"

			var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
			if(!new_state) return

			switch(new_state)
				if("Normal")
					organ_data[organ] = null
				if("Assisted")
					organ_data[organ] = "assisted"
				if("Mechanical")
					organ_data[organ] = "mechanical"

		if("spawnpoint")
			var/list/spawnkeys = list()
			for(var/S in spawntypes)
				spawnkeys += S
			var/choice = input(user, "Where would you like to spawn when latejoining?") as null|anything in spawnkeys
			if(!choice || !spawntypes[choice])
				spawnpoint = "Arrivals Shuttle"
				EditCharacterMenu( user )
				return
			spawnpoint = choice

		if("home_system")
			var/choice = input(user, "Please choose a home system.") as null|anything in home_system_choices + list("Unset","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a home system.")  as text|null
				if(raw_choice)
					home_system = sanitize(raw_choice)
				return
			home_system = choice
		if("citizenship")
			var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter your current citizenship.", "Character Preference") as text|null
				if(raw_choice)
					citizenship = sanitize(raw_choice)
				EditCharacterMenu( user )
				return
			citizenship = choice
		if("faction")
			var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a faction.")  as text|null
				if(raw_choice)
					faction = sanitize(raw_choice)
				EditCharacterMenu( user )
				return
			faction = choice
		if("religion")
			var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
			if(!choice)
				return
			if(choice == "Other")
				var/raw_choice = input(user, "Please enter a religon.")  as text|null
				if(raw_choice)
					religion = sanitize(raw_choice)
				EditCharacterMenu( user )
				return
			religion = choice

		if( "loadout_add" )
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

		if( "loadout_remove" )
			if(isnull(gear) || !islist(gear))
				gear = list()
			if(!gear.len)
				return

			var/i_remove = text2num(href_list["gear"])

			if( i_remove )
				if(i_remove < 1 || i_remove > gear.len) return
				gear.Cut(i_remove, i_remove + 1)
				EditCharacterMenu( user )
				return

			var/choice = input(user, "Select gear to remove: ") as null|anything in gear
			if(!choice)
				return

			gear -= choice

		if( "loadout_clear" )
			gear.Cut()

		if( "acc_items" )
			var/list/valid_gear_choices = list()

			for(var/gear_name in account_items)
				var/datum/gear/G = gear_datums[gear_name]
				if( !G )
					continue
				if( !G.account )
					continue
				valid_gear_choices += gear_name

			if( !valid_gear_choices || !valid_gear_choices.len )
				src << "There are no valid items tied to your account."
				return

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
		if( "name_random" )
			name = random_name(gender,species)

		if( "all_random" )
			randomize_appearance_for()	//no params needed

		if("gender")
			if(gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if("job_antag")
			var/num = text2num(href_list["num"])
			job_antag ^= (1<<num)

		if( "close" )
			user.client.prefs.ClientMenu( user )
			EditCharacterMenuDisable( user )

		if( "species_menu" )
			// Actual whitelist checks are handled elsewhere, this is just for accessing the preview window.
			var/choice = input("Which species would you like to look at?") as null|anything in playable_species
			if(!choice) return
			species_preview = choice
			SpeciesMenu( user )
			EditCharacterMenuDisable( user )
			return 1

		if( "pAI" )
			paiController.recruitWindow(user, 0)
			return 1

		if( "records_menu" )
			RecordsMenu( user )
			EditCharacterMenuDisable( user )
			return 1

		if( "antag_options_menu" )
			AntagOptionsMenu( user )
			EditCharacterMenuDisable( user )
			return 1

		if( "flavor_text_menu" )
			FlavorTextMenu( user )
			EditCharacterMenuDisable( user )
			return 1

		if( "job_menu" )
			JobChoicesMenu( user )
			EditCharacterMenuDisable( user )
			return 1

	user.client.prefs.ClientMenu( user )
	EditCharacterMenu( user )