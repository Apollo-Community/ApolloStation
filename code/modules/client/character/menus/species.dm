/datum/character/proc/SpeciesMenu(mob/user)
	var/menu_name = "species_menu"

	if(!species_preview || !(species_preview in all_species))
		species_preview = "Human"
	var/datum/species/current_species = all_species[species_preview]
	var/dat = "<body>"
	dat += "<center><h2>[current_species.name] <a href='byond://?src=\ref[src];character=[menu_name];task=change_selection'>change</a></h2></center><hr/>"
	dat += "<table class='outline'>"
	dat += "<tr>"
	dat += "<td width = 400>[current_species.blurb]</td>"
	dat += "<td width = 200 align='center'>"
	if("preview" in icon_states(current_species.icobase))
		usr << browse_rsc(icon(current_species.icobase,"preview"), "species_preview_[current_species.name].png")
		dat += "<img src='species_preview_[current_species.name].png' width='64px' height='64px'><br/><br/>"
	dat += "<b>Language:</b> [current_species.language]<br/>"
	dat += "<small>"
	if(current_species.flags & CAN_JOIN)
		dat += "</br><b>Often present on human stations.</b>"
	if(( current_species.flags & IS_WHITELISTED ))
		dat += "</br><b>Whitelist restricted.</b>"
	if(current_species.flags & NO_BLOOD)
		dat += "</br><b>Does not have blood.</b>"
	if(current_species.flags & NO_BREATHE)
		dat += "</br><b>Does not breathe.</b>"
	if(current_species.flags & NO_SCAN)
		dat += "</br><b>Does not have DNA.</b>"
	if(current_species.flags & NO_PAIN)
		dat += "</br><b>Does not feel pain.</b>"
	if(current_species.flags & NO_SLIP)
		dat += "</br><b>Has excellent traction.</b>"
	if(current_species.flags & HAS_SKIN_TONE)
		dat += "</br><b>Has a variety of skin tones.</b>"
	if(current_species.flags & HAS_SKIN_COLOR)
		dat += "</br><b>Has a variety of skin colours.</b>"
	if(current_species.flags & HAS_EYE_COLOR)
		dat += "</br><b>Has a variety of eye colours.</b>"
	if(current_species.flags & IS_PLANT)
		dat += "</br><b>Has a plantlike physiology.</b>"
	if(current_species.flags & IS_SYNTHETIC)
		dat += "</br><b>Is machine-based.</b>"
	if(current_species.flags & NO_CRYO)
		dat += "</br><b>Cannot use cryogenics.</b>"
	if(current_species.flags & NO_ROBO_LIMBS)
		dat += "</br><b>Cannot have robotic limbs.</b>"
	dat += "</small></td>"
	dat += "</tr>"
	dat += "</table><center><hr/>"

	if( config.usealienwhitelist )
		if(!is_alien_whitelisted( user, current_species.name ))
			dat += "<font color='red'><b>You cannot play as this species.</br><small>If you wish to be whitelisted, you can make an application post on <a href='byond://?src=\ref[src];character=open_whitelist_forum'>the forums</a>.</small></b></font></br>"
		else if( !( current_species.flags & CAN_JOIN ) && !check_rights( R_ADMIN, 0 ))
			dat += "<font color='red'><b>You cannot create a new character with this species!</br><small>You'll need to find some other way to play as this race...</small></b></font></br>"
		else
			dat += "<a href='byond://?src=\ref[src];character=[menu_name];task=select_species;species=[species_preview]'>select</a>"
	else
		dat += "<a href='byond://?src=\ref[src];character=[menu_name];task=select_species;species=[species_preview]'>select</a>"

	dat += "</center></body>"

	menu.set_user( user )
	menu.set_content( dat )
	menu.open()

/datum/character/proc/SpeciesMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "select_species" )
			winshow( user, "species_menu", 0)
			var/prev_species = species
			species = href_list["species"]
			if(prev_species != species)
				//grab one of the valid hair styles for the newly chosen species
				var/list/valid_hairstyles = list()
				for(var/hairstyle in hair_styles_list)
					var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
					if(gender == MALE && S.gender == FEMALE)
						continue
					if(gender == FEMALE && S.gender == MALE)
						continue
					if( !(species in S.species_allowed))
						continue
					valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

				if(valid_hairstyles.len)
					hair_style = pick(valid_hairstyles)
				else
					//this shouldn't happen
					hair_style = hair_styles_list["Bald"]

				//grab one of the valid facial hair styles for the newly chosen species
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

				if(valid_facialhairstyles.len)
					hair_face_style = pick(valid_facialhairstyles)
				else
					//this shouldn't happen
					hair_face_style = facial_hair_styles_list["Shaved"]

				//reset hair colour and skin colour
				hair_color = rgb( 0, 0, 0 )

				skin_tone = 0
			EditCharacterMenu(user)
		if( "change_selection" )
			// Actual whitelist checks are handled elsewhere, this is just for accessing the preview window.
			var/choice = input("Which species would you like to look at?") as null|anything in playable_species
			if(!choice) return
			species_preview = choice

			SpeciesMenu(user)

