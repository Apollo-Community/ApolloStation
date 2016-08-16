/datum/character/proc/EditCharacterMenu(mob/user)
	if(!istype( user ) || !user.client)	return

	var/datum/species/S = all_species[species]

	var/menu_name = "edit_character"

	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")

	. = "<html><body><center>"
	. += "<b>Appearence</b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=records_menu'>Records</a></b>"
	if( !temporary )
		. += " - "
		. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=job_menu'>Occupation</a></b>"
		. += " - "
		. += "<b><a href='byond://?src=\ref[src];character=switch_menu;task=antag_options_menu'>Antag Options</a></b>"
	. += "</center><hr>"

	// APPEARENCE
	. += "<table><tr><td valign='top'>"
	. += "<table class='outline'><tr>"
	. += "<th>Name:</th>"
	if( new_character )
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=name'><b>[name]</b></a></td>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=name_random'>Randomize</A></td>"
	else
		. += "<td>[name]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Gender:</th>"
	if( new_character )
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a></td>"
	else
		. += "<td>[gender == MALE ? "Male" : "Female"]</td>"
	. += "<td rowspan='3'><table><tr><td style='text-align:center'>"
	. += "<img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64>"
	. += "</td></tr></table></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Age:</th>"
	//if( new_character )
	. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=age'>[age]</a></td>"
	//else
	//	. += "<td>[age]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<th>Species:</th>"
	if( new_character )
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=species_menu'>[species]</a></td>"
	else
		. += "<td>[species]</td>"
	. += "</tr>"
	. += "</table>"

	. += "</td><td valign='top'>"


	var/total_cost = 0
	if(!islist(gear)) gear = list()

	if(gear && gear.len)
		for(var/i = 1; i <= gear.len; i++)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G && !G.account)
				total_cost += G.cost

	. += "<table class='border'>"
	. += "<tr>"
	. += "<th>Custom Loadout:</th>"
	. += "<th>[total_cost] / [MAX_GEAR_COST] points</th>"
	. += "<th><a href='byond://?src=\ref[src];character=[menu_name];task=loadout_add'>add</a>"
	if(gear && gear.len)
		. += " / <a href='byond://?src=\ref[src];character=[menu_name];task=loadout_clear'>clear</a></th>"
	else
		. += "</th>"

	//. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=acc_items'><b>Account Items</b></a></td>"
	. += "</tr>"

	if(gear && gear.len)
		for(var/i = 1; i <= gear.len; i++)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G)
				. += "<tr>"
				. += "<td>[gear[i]]</td>"
				if( !G.account )
					. += "<td>([G.cost] points)</td>"
				else
					. += "<td>(Account)</td>"

				. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=loadout_remove;gear=[i]'>remove</a></td>"
				. += "</tr>"
	else
		. += "<td colspan='3'>None.</td>"
	. += "</td>"
	. += "</tr>"
	. += "</table>"
	. += "</td></tr></table>"

	. += "<table>"
	. += "<tr>"
	. += "<th colspan='3' style='text-align:center'><b>Body</b> <a href='byond://?src=\ref[src];character=[menu_name];task=all_random'>Randomize</A></th>"
	. += "</tr>"
	. += "<tr>"
	. += "<td valign='top'>"
	. += "<table><tr><td valign='top'>"

	. += "<table class='outline'>"
	if( S.flags & IS_SYNTHETIC )
		. += "<tr>"
		. += "<th rowspan='2'>Monitor:</th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=hair_style'>[hair_style]</a></td>"
		. += "</tr>"
	else if( !( S.flags & IS_PLANT ))
		. += "<tr>"
		. += "<th rowspan='2'>Hair:</th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=hair_color'>Color</a></td>"
		. += "<td><div style='display:inline; background-color:[hair_color]; border-collapse:collapse;'><font face='fixedsys' size='3' color='[hair_color]'>__</font></div></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td colspan='2'><a href='byond://?src=\ref[src];character=[menu_name];task=hair_style'>[hair_style]</a></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<th rowspan='2'><b>Facial Hair:</b></th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=hair_face_color'>Color</a></td>"
		. += "<td><div style='display:inline; background-color:[hair_face_color]; border-collapse:collapse;'><font face='fixedsys' size='3' color='[hair_face_color]'>__</font></div></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td colspan='2'><a href='byond://?src=\ref[src];character=[menu_name];task=hair_face_style'>[hair_face_style]</a></td>"
		. += "</tr>"

	if( S.flags & HAS_EYE_COLOR )
		. += "<tr>"
		. += "<th>Eyes:</th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=eye_color'>Color</a></td>"
		. += "<td><div style='display:inline; background-color:[eye_color]; border-collapse:collapse;'><font face='fixedsys' size='3' color='[eye_color]'>__</font></div></td>"
		. += "</tr>"

	if( S.flags & HAS_SKIN_COLOR || S.flags & HAS_SKIN_TONE )
		. += "<tr>"
		. += "<th rowspan='2' valign='top'>Skin:</th>"
		if( S.flags & HAS_SKIN_TONE )
			. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=skin_tone'>Tone: [-skin_tone+SKIN_TONE_DEFAULT]/[SKIN_TONE_MAX]</a></td>"
		if( S.flags & HAS_SKIN_COLOR )
			. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=skin_color'>Color</a></td>"
			. += "<td><div style='display:inline; background-color:[skin_color]; border-collapse:collapse;'><font face='fixedsys' size='3' color='[skin_color]'>__</font></div></td>"
		. += "</tr>"
	. += "</table>"

	. += "</td><td valign='top'>"

	. += "<table class='outline'>"
	if( S.flags & HAS_UNDERWEAR )
		. += "<tr>"
		. += "<th>Underwear:</th>"
		if(gender == MALE)
			. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=underwear'>[underwear_m[underwear]]</a></td>"
		else
			. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=underwear'>[underwear_f[underwear]]</a></td>"

		. += "<tr>"
		. += "<th>Undershirt:</th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=undershirt'>[undershirt_t[undershirt]]</a></td>"
		. += "</tr>"

	. += "<tr>"
	. += "<th>Backpack Type:</th>"
	. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=backpack'>[backpacklist[backpack]]</a></td>"
	. += "</tr>"
	. += "</table>"

	. += "</td><td valign='top'>"

	if( !( S.flags & NO_ROBO_LIMBS ))
		. += "<table class='border'>"
		. += "<tr>"
		. += "<th>Organs \& Limbs:</th>"
		. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=organs_adjust'><b>adjust</b></a></td>"
		. += "</tr>"

		//display limbs below

		var/organ_count = 0
		for(var/name in organ_data)
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

			if( !status )
				continue

			organ_count++
			. += "<tr>"
			if(status == "cyborg" || status == "mechanical")
				. += "<td>Mechanical [organ_name]</td>"
			else if(status == "amputated")
				. += "<td>Amputated [organ_name]</td>"
			else if(status == "assisted")
				switch(organ_name)
					if("heart")
						. += "<td>Pacemaker-assisted [organ_name]</td>"
					if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
						. += "<td>Surgically altered [organ_name]</td>"
					if("eyes")
						. += "<td>Retinal overlayed [organ_name]</td>"
					else
						. += "<td>Mechanically assisted [organ_name]</td>"
			. += "<td><a href='byond://?src=\ref[src];character=[menu_name];task=limbs_organ_remove;limb=[name]'>remove</a></td>"
			. += "</tr>"
		if( !organ_count )
			. += "<tr>"
			. += "<td colspan='2'>None</td>"
			. += "</tr>"
		. += "</table>"
	. += "</td></tr></table>"

	. += "</td></tr>"

	. += "<tr><td colspan='3'>"
	. += "<table class='border'>"
	. += "<col width='90'>"
	. += "<tr>"
	. += "<th colspan='3'>Flavor Text</th>"
	. += "</tr>"

	. += "<tr>"
	. += "<th><a href='byond://?src=\ref[src];character=[menu_name];task=human'>Humanoids</a>:</th>"
	. += "<td>[TextPreview(flavor_texts_human)]</td>"
	. += "</tr>"

	. += "<tr>"
	. += "<th><a href ='byond://?src=\ref[src];character=[menu_name];task=robot'>Cyborg</a>:</th>"
	. += "<td>[TextPreview(flavor_texts_robot)]</td>"
	. += "</tr>"

	. += "</table>"

	. += "</td></tr>"
	. += "</table>"

	. += "<hr><center>"
	if(!IsGuestKey(user.key))
		. += "<a href='byond://?src=\ref[src];character=[menu_name];task=save'>Save Setup</a> - "
		if( !temporary )
			. += "<a href='byond://?src=\ref[src];character=[menu_name];task=reset'>Reset Changes</a> - "

	. += "<a href='byond://?src=\ref[src];character=[menu_name];task=close'>Done</a>"
	. += "</center>"
	. += "</body></html>"

	menu.set_user( user )
	menu.set_content( . )
	menu.open()

/datum/character/proc/EditCharacterMenuDisable( mob/user )
	menu.close()

/datum/character/proc/EditCharacterMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "save" )
			if( !saveCharacter( 1 ))
				alert( user, "Character could not be saved to the database, please contact an admin." )

		if( "reset" )
			if( !loadCharacter( name ))
				alert( user, "No savepoint to reset from. You need to save your character first before you can reset." )

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
				change_age( text2num( new_age ))

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
			var/new_skin_tone = input(user, "Choose your character's skin-tone:\n(Light [SKIN_TONE_MIN] - [SKIN_TONE_MAX] Dark)", "Character Preference")  as num|null
			if( new_skin_tone || new_skin_tone == 0 )
				skin_tone = SKIN_TONE_DEFAULT-max( min( round( new_skin_tone ), SKIN_TONE_MAX ), SKIN_TONE_MIN )

		if("skin_color")
			if(species == "Unathi" || species == "Tajara" || species == "Skrell" || species == "Wryn")
				var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", skin_color ) as color|null
				if(new_skin)
					skin_color = new_skin

		if("backpack")
			var/new_backpack = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backpacklist
			if(new_backpack)
				backpack = backpacklist.Find(new_backpack)

		if("organs_adjust")
			var/choice = input(user, "Which type do you want to change?") as null|anything in list("Limb","Organ")
			if( choice == "Limb" )
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
			else if( choice == "Organ" )
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

		if( "limbs_organ_remove" )
			var/organ_reset = href_list["limb"]

			if( !organ_data )
				organ_data = list()

			if( organ_reset )
				if( !( organ_reset in organ_data )) return
				organ_data[organ_reset] = null


		if( "loadout_add" )
			if( alert( user, "What type of loadout item do you want to add?", "Loadout Addition","Normal Item","Account Item" ) == "Normal Item" )
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
			else
				var/list/valid_gear_choices = list()

				if( !user || !user.client || !user.client.prefs || !user.client.prefs.account_items )
					return

				for(var/gear_name in user.client.prefs.account_items)
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

		if( "name_random" )
			name = random_name(gender,species)

		if( "all_random" )
			randomize_appearance()	//no params needed

		if("gender")
			if(gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if( "human" )
			var/msg = sanitize(input(usr,"Give a general description of your character. This will be shown regardless of clothing, and may NOT include OOC notes and preferences.","Flavor Text",html_decode(flavor_texts_human)) as message, extra = 0)
			flavor_texts_human = msg

		if( "robot" )
			var/msg = sanitize(input(usr,"Give a general description for when you're a cyborg. It will be used for any module without individual setting. It may NOT include OOC notes and preferences.","Flavour Text",html_decode(flavor_texts_robot)) as message, extra = 0)
			flavor_texts_robot = msg

		if( "close" )
			if( alert( user, "Do you want to save your changes?", "Save Character","Yes","No" ) == "Yes" )
				if( !saveCharacter( 0 ))
					alert( user, "Character could not be saved to the database, please contact an admin." )

			EditCharacterMenuDisable( user )

			if( istype( user, /mob/new_player ))
				user.client.prefs.ClientMenu( user )

			return 1

		if( "species_menu" )
			// Actual whitelist checks are handled elsewhere, this is just for accessing the preview window.
			var/choice = input("Which species would you like to look at?") as null|anything in playable_species
			if(!choice) return
			species_preview = choice
			SpeciesMenu( user )
			return 1

	EditCharacterMenu( user )