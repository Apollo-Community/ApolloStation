/proc/saveAllActiveCharacters()
	for( var/datum/character/C in all_characters )
		if( !C.new_character ) // If they've been saved to the database previously
			C.saveCharacter()

/datum/character/proc/saveCharacter( var/prompt = 0 )
	if( !ckey )
		world << "No given ckey"
		return 0

	if ( IsGuestKey( ckey ))
		world << "Is a guest ckey"
		return 0

	if( prompt && ckey )
		var/client
		for( client in clients )
			if( ckey( client:ckey ) == ckey )
				break

		var/response
		if( new_character )
			response = alert(client, "Are you sure you're finished with character setup? You will no longer be able to change your character name, age, gender, or species after this.", "Save Character","Yes","No")
		else
			response = alert(client, "Are you sure you want to save?", "Save Character","Yes","No")

		if( response == "No" )
			return 1

	new_character = 0

	var/list/variables = list()

	variables["ckey"] = ckey( ckey )
	variables["name"] = sql_sanitize_text( name )
	variables["gender"] = sql_sanitize_text( gender )
	variables["birth_date"] = list2params( birth_date )
	variables["spawnpoint"] = sql_sanitize_text( spawnpoint )
	variables["blood_type"] = sql_sanitize_text( blood_type )

	// Default clothing

	var/list/underwear_options
	if(gender == MALE)
		underwear_options = underwear_m
	else
		underwear_options = underwear_f

	variables["underwear"] = sanitize_integer( underwear, 1, underwear_options.len, initial(underwear))
	variables["undershirt"] = sanitize_integer( undershirt, 1, undershirt_t.len, initial(undershirt))
	variables["backpack"] = sanitize_integer( backpack, 1, backpacklist.len, initial(backpack))

	// Cosmetic features
	variables["hair_style"] = sql_sanitize_text( hair_style )
	variables["hair_face_style"] = sql_sanitize_text( hair_face_style )
	variables["hair_color"] = sanitize_hexcolor( hair_color )
	variables["hair_face_color"] = sanitize_hexcolor( hair_face_color )

	variables["skin_tone"] = sanitize_integer( skin_tone, SKIN_TONE_DEFAULT-SKIN_TONE_MAX, SKIN_TONE_DEFAULT-SKIN_TONE_MIN, SKIN_TONE_DEFAULT )
	variables["skin_color"] = sanitize_hexcolor( skin_color )

	variables["eye_color"] = sanitize_hexcolor( eye_color )

	// Character species
	variables["species"] = sql_sanitize_text( species )

	// Secondary language
	var/datum/language/L = additional_language
	if( istype( L ))
		variables["additional_language"] = sql_sanitize_text( L.name )

	// Custom spawn gear
	variables["gear"] = list2params( gear )

	// Some faction information.
	variables["home_system"] = sql_sanitize_text( home_system )
	variables["citizenship"] = sql_sanitize_text( citizenship )
	variables["faction"] = sql_sanitize_text( faction )
	variables["religion"] = sql_sanitize_text( religion )

	// Jobs, uses bitflags
	variables["department"] = sanitize_integer( department.department_id, 0, 255, 0 )
	variables["roles"] = list2params( roles )

	// Special role selection
	variables["job_antag"] = sanitize_integer( job_antag, 0, BITFLAGS_MAX, 0 )

	// Keeps track of preferrence for not getting any wanted jobs
	variables["alternate_option"] = sanitize_integer( alternate_option, 0, BITFLAGS_MAX, 0 )

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	variables["organ_data"] = list2params( organ_data )

	// The default name of a job like "Medical Doctor"
	variables["player_alt_titles"] = list2params( player_alt_titles )

	// Flavor texts
	variables["flavor_texts_human"] = sql_sanitize_text( flavor_texts_human )
	variables["flavor_texts_robot"] = sql_sanitize_text( flavor_texts_robot )

	// Character notes, these are written by other people. Format is list( datetime = note )
	variables["med_notes"] = list2params( med_notes )
	variables["sec_notes"] = list2params( sec_notes )
	variables["gen_notes"] = list2params( gen_notes )

	// Character records, these are written by the player
	variables["med_record"] = sql_sanitize_text( med_record )
	variables["sec_record"] = sql_sanitize_text( sec_record )
	variables["gen_record"] = sql_sanitize_text( gen_record )
	variables["exploit_record"] = sql_sanitize_text( exploit_record )

	// Relation to NanoTrasen
	variables["nanotrasen_relation"] = sql_sanitize_text( nanotrasen_relation )

	// Character disabilities
	variables["disabilities"] = sanitize_integer( disabilities, 0, BITFLAGS_MAX, 0 )

	// Location of traitor uplink
	variables["uplink_location"] = sql_sanitize_text( uplink_location )

	// Unique identifiers
	variables["fingerprints"] = sql_sanitize_text( fingerprints )
	variables["DNA"] = sql_sanitize_text( DNA )
	variables["unique_identifier"] = sql_sanitize_text( unique_identifier )

	var/list/names = list()
	var/list/values = list()
	for( var/name in variables )
		names += sql_sanitize_text( name )
		values += variables[name]

	establish_db_connection()
	if( !dbcon.IsConnected() )
		world << "No database connected"
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM characters WHERE ckey = '[variables["ckey"]]' AND name = '[variables["name"]]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			world << "Invalid SQL ID"
			return 0

	if(sql_id)
		if( names.len != values.len )
			world << "Names length does not equal values length"
			return 0

		var/query_params = ""
		for( var/i = 1; i < names.len; i++ )
			query_params += "[names[i]]='[values[i]]'"
			if( i != names.len-1 )
				query_params += ","

		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE characters SET [query_params] WHERE ckey = '[variables["ckey"]]' AND name = '[variables["name"]]'")
		if( !query_update.Execute())
			world << "Could not update"
			return 0
	else
		var/query_names = list2text( names, "," )
		query_names += sql_sanitize_text( ", id" )

		var/query_values = list2text( values, "','" )
		query_values += "', null"

		// This needs a single quote before query_values because otherwise there will be an odd number of single quotes
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO characters ([query_names]) VALUES ('[query_values])")
		if( !query_insert.Execute() )
			world << "Could not insert"
			return 0

	return 1

/datum/character/proc/loadCharacter( var/character_name )
	if( !ckey )
		world << "No ckey"
		return 0

	if( !character_name )
		world << "No character name"
		return 0

	new_character = 0 // If we're loading from the database, we're obviously a pre-existing character

	var/list/variables = list()

	// Base information
	variables["name"] = "text"
	variables["gender"] = "text"
	variables["birth_date"] = "birth_date"
	variables["spawnpoint"] = "text"
	variables["blood_type"] = "text"

	// Default clothing
	variables["underwear"] = "number"
	variables["undershirt"] = "number"
	variables["backpack"] = "number"

	// Cosmetic features
	variables["hair_style"] = "text"
	variables["hair_face_style"] = "text"
	variables["hair_color"] = "text"
	variables["hair_face_color"] = "text"
	variables["skin_tone"] = "number"
	variables["skin_color"] = "text"
	variables["eye_color"] = "text"

	// Character species
	variables["species"] = "text"

	// Secondary language
	variables["additional_language"] = "language"

	// Custom spawn gear
	variables["gear"] = "params"

	// Some faction information.
	variables["home_system"] = "text"
	variables["citizenship"] = "text"
	variables["faction"] = "text"
	variables["religion"] = "text"

	// Jobs, uses bitflags
	variables["roles"] = "params"
	variables["department"] = "department"

	// Special role selection
	variables["job_antag"] = "number"

	// Keeps track of preferrence for not getting any wanted jobs
	variables["alternate_option"] = "number"

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	variables["organ_data"] = "params"

	// The default name of a job like "Medical Doctor"
	variables["player_alt_titles"] = "params"

	// Flavor texts
	variables["flavor_texts_human"] = "text"
	variables["flavor_texts_robot"] = "text"

	// Character notes, these are written by other people
	variables["med_notes"] = "params"
	variables["sec_notes"] = "params"
	variables["gen_notes"] = "params"

	// Character records, these are written by the player
	variables["med_record"] = "text"
	variables["sec_record"] = "text"
	variables["gen_record"] = "text"
	variables["exploit_record"] = "text"

	// Relation to NanoTrasen
	variables["nanotrasen_relation"] = "text"

	// Character disabilities
	variables["disabilities"] = "number"

	// Location of traitor uplink
	variables["uplink_location"] = "text"

	variables["fingerprints"] = "text"
	variables["DNA"] = "text"
	variables["unique_identifier"] = "text"

	var/query_names = list2text( variables, "," )
	var/sql_ckey = ckey( ckey )
	var/sql_character_name = sql_sanitize_text( character_name )

	var/DBQuery/query = dbcon.NewQuery("SELECT [query_names] FROM characters WHERE ckey = '[sql_ckey]' AND name = '[sql_character_name]'")
	if( !query.Execute() )
		world << "Could not run select query"
		return 0

	if( !query.NextRow() )
		world << "Not a character in database"
		return 0

	for( var/i = 1; i < variables.len; i++ )
		var/value = query.item[i]

		switch( variables[variables[i]] )
			if( "text" )
				value = sanitize_text( value, "ERROR" )
			if( "number" )
				value = text2num( value )
			if( "params" )
				value = params2list( value )
				if( !value )
					value = list()
			if( "list" )
				value = text2list( value )
				if( !value )
					value = list()
			if( "language" )
				if( value in all_languages )
					value = all_languages[value]
				else
					value = "None"
			if( "birth_date" )
				birth_date = params2list( value )
				for( var/j = 1; j <= birth_date.len; j++ )
					birth_date[j] = text2num( birth_date[j] )

				if( !birth_date || !birth_date.len )
					change_age( 30 )

				calculate_age()
				continue
			if( "department" )
				LoadDepartment( text2num( value ))
				continue // Dont need to set the variable on this one

		vars[variables[i]] = value

	return 1

/datum/character/proc/addRecordNote( var/type, var/note, var/title )
	var/timestamp = "[worldtime2text()] [print_date( universe.date )]"
	if( title )
		timestamp += " - [title]"

	switch( type )
		if( "general" )
			gen_notes[timestamp] = html_encode( note )
		if( "medical" )
			med_notes[timestamp] = html_encode( note )
		if( "security" )
			sec_notes[timestamp] = html_encode( note )

/datum/character/proc/randomize_appearance( var/random_age = 0 )
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender, species)
	hair_face_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	randomize_skin_color()
	underwear = rand(1,underwear_m.len)
	undershirt = rand(1,undershirt_t.len)
	backpack = 2
	if( random_age )
		age = rand(AGE_MIN,AGE_MAX)

/datum/character/proc/randomize_appearance_for(var/mob/living/carbon/human/H)
	randomize_appearance(1)
	if(H)
		copy_to(H,1)

/datum/character/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		hair_face_color = hair_color
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			hair_color = rgb( red, green, blue )
		if("facial")
			hair_face_color = rgb( red, green, blue )

/datum/character/proc/change_age( var/new_age, var/age_min = AGE_MIN, var/age_max = AGE_MAX )
	new_age = max(min( round( new_age ), age_max), age_min)

	var/birth_year = game_year-new_age

	var/birth_month = text2num(time2text(world.timeofday, "MM")) - rand( 1, 12 )

	if( birth_month < 1 )
		birth_year++
		birth_month += 12

	var/birth_day = rand( 1, getMonthDays( birth_month ))

	birth_date = list( birth_year, birth_month, birth_day )
	age = calculate_age()

/datum/character/proc/calculate_age()
	var/cur_year = game_year
	var/cur_month = text2num(time2text(world.timeofday, "MM"))
	var/cur_day = text2num(time2text(world.timeofday, "DD"))

	var/birth_year = birth_date[1]
	var/birth_month = birth_date[2]
	var/birth_day = birth_date[3]

	age = cur_year-birth_year

	if( cur_month > birth_month )
		age++
	else if( cur_month == birth_month )
		if( cur_day >= birth_day )
			age++

	return age

/datum/character/proc/print_birthdate()
	if( !birth_date || birth_date.len < 3 )
		calculate_age()
		if( !birth_date || birth_date.len < 3 )
			change_age( 30 )
	return print_date( birth_date )

/datum/character/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	eye_color = rgb( red, green, blue )

/datum/character/proc/randomize_skin_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	skin_color = rgb( red, green, blue )

/datum/character/proc/update_preview_icon()		//seriously. This is horrendous.
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	var/icon/icobase
	var/datum/species/current_species = all_species[species]

	if(current_species)
		icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	preview_icon = new /icon(icobase, "torso_[g]")
	preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
	preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)

	for(var/name in list("r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","l_arm","l_hand"))
		if(organ_data[name] == "amputated") continue

		var/icon/temp = new /icon(icobase, "[name]")
		if(organ_data[name] == "cyborg")
			temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

		preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(current_species && (current_species.tail))
		var/icon/temp = new/icon("icon" = current_species.effect_icons, "icon_state" = "[current_species.tail]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)

	// Skin color
	if(current_species && (current_species.flags & HAS_SKIN_COLOR))
		preview_icon.Blend( skin_color, ICON_ADD )

	// Skin tone
	if(current_species && (current_species.flags & HAS_SKIN_TONE))
		if (skin_tone >= 0)
			preview_icon.Blend(rgb(skin_tone, skin_tone, skin_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-skin_tone,  -skin_tone,  -skin_tone), ICON_SUBTRACT)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
	if ((current_species && (current_species.flags & HAS_EYE_COLOR)))
		eyes_s.Blend(eye_color, ICON_ADD)

	var/datum/sprite_accessory/h_style = hair_styles_list[hair_style]
	if(h_style)
		var/icon/hair_s = new/icon("icon" = h_style.icon, "icon_state" = "[h_style.icon_state]_s")
		hair_s.Blend( hair_color, ICON_ADD )
		eyes_s.Blend( hair_s, ICON_OVERLAY )

	var/datum/sprite_accessory/facial_h_style = facial_hair_styles_list[hair_face_style]
	if(facial_h_style)
		var/icon/facial_s = new/icon("icon" = facial_h_style.icon, "icon_state" = "[facial_h_style.icon_state]_s")
		facial_s.Blend(hair_face_color, ICON_ADD)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/underwear_s = null
	if(underwear > 0 && underwear < 7 && current_species.flags & HAS_UNDERWEAR)
		underwear_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "underwear[underwear]_[g]_s")

	var/icon/undershirt_s = null
	if(undershirt > 0 && undershirt < 5 && current_species.flags & HAS_UNDERWEAR)
		undershirt_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "undershirt[undershirt]_s")

	var/icon/clothes_s = null
	var/datum/job/job = job_master.GetJob( GetHighestLevelJob() )

	clothes_s = job.make_preview_icon( backpack )

	if(disabilities & NEARSIGHTED)
		preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "glasses"), ICON_OVERLAY)

	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(underwear_s)
		preview_icon.Blend(underwear_s, ICON_OVERLAY)
	if(undershirt_s)
		preview_icon.Blend(undershirt_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)

	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(eyes_s)
	qdel(underwear_s)
	qdel(undershirt_s)
	qdel(clothes_s)
