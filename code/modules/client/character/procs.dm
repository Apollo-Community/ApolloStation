/datum/character/New( var/key, var/new_char = 1, var/temp = 1 )
	ckey = ckey( key )

	blood_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

	gender = pick(MALE, FEMALE)
	name = random_name(gender,species)

	gear = list()

	DNA = md5( "DNA[name][blood_type][gender][eye_color][time2text(world.timeofday,"hh:mm")]" )
	fingerprints = md5( DNA )
	unique_identifier = md5( fingerprints )

	new_character = new_char
	temporary = temp

	change_age( 30 )

	if( !department )
		LoadDepartment( CIVILIAN )

	menu = new( null, "creator", "Character Creator", 710, 610 )
	menu.window_options = "focus=0;can_close=0;"

	all_characters += src

/datum/character/Destroy()
	all_characters -= src

	..()

// Primarily for copying role data to antags
/datum/character/proc/copy_metadata_to( var/datum/character/C )
	C.roles = src.roles
	C.department = src.department
	C.antag_data = src.antag_data.Copy()
	C.uplink_location = src.uplink_location

/datum/character/proc/copy_to( mob/living/carbon/human/character )
	if( !istype( character ))
		return

	if(config.humans_need_surnames)
		var/firstspace = findtext(name, " ")
		var/name_length = length(name)
		if(!firstspace)	//we need a surname
			name += " [pick(last_names)]"
		else if(firstspace == name_length)
			name += "[pick(last_names)]"

	char_mob = character

	character.gender = gender
	character.real_name = name
	character.name = character.real_name
	if(character.dna)
		character.dna.real_name = character.real_name

	character.character = src

	character.set_species( species, 1 )

	// Destroy/cyborgize organs
	for(var/name in organ_data)
		var/status = organ_data[name]
		var/datum/organ/external/O = character.organs_by_name[name]
		if(O)
			if(status == "amputated")
				O.amputated = 1
				O.status |= ORGAN_DESTROYED
				O.destspawn = 1
			else if(status == "cyborg")
				O.status |= ORGAN_ROBOT
		else
			var/datum/organ/internal/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.mechanize()

	if(underwear > underwear_m.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES

	if(undershirt > undershirt_t.len || undershirt < 1)
		undershirt = 0

	if(backpack > 4 || backpack < 1)
		backpack = 1 //Same as above

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(gender in list(PLURAL, NEUTER))
		if(isliving(character)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			gender = MALE

	round_number = universe.round_number

/datum/character/proc/saveCharacter( var/prompt = 0 )
	if( istype( char_mob ))
		char_mob.fully_replace_character_name( char_mob.real_name, name )
		copy_to( char_mob )
		char_mob.update_hair()
		char_mob.update_body()
		char_mob.check_dna( char_mob )


	if( temporary ) // If we're just a temporary character, dont save to database
		return 1

	if( !ckey )
		testing( "SAVE CHARACTER: Didn't save [name] because they didn't have a ckey" )
		return 0

	if ( IsGuestKey( ckey ))
		testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because they were a guest character" )
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
	variables["name"] = html_encode( sql_sanitize_text( name ))
	variables["gender"] = html_encode( sql_sanitize_text( gender ))
	variables["birth_date"] = html_encode( list2params( birth_date ))
	variables["spawnpoint"] = html_encode( sql_sanitize_text( spawnpoint ))
	variables["blood_type"] = html_encode( sql_sanitize_text( blood_type ))

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
	variables["hair_style"] = html_encode( sql_sanitize_text( hair_style ))
	variables["hair_face_style"] = html_encode( sql_sanitize_text( hair_face_style ))
	variables["hair_color"] = sanitize_hexcolor( hair_color )
	variables["hair_face_color"] = sanitize_hexcolor( hair_face_color )

	variables["skin_tone"] = sanitize_integer( skin_tone, SKIN_TONE_DEFAULT-SKIN_TONE_MAX, SKIN_TONE_DEFAULT-SKIN_TONE_MIN, SKIN_TONE_DEFAULT )
	variables["skin_color"] = sanitize_hexcolor( skin_color )

	variables["eye_color"] = sanitize_hexcolor( eye_color )

	// Character species
	variables["species"] = html_encode( sql_sanitize_text( species ))

	// Secondary language
	var/datum/language/L = additional_language
	if( istype( L ))
		variables["additional_language"] = html_encode( sql_sanitize_text( L.name ))

	// Custom spawn gear
	variables["gear"] = html_encode( list2params( gear ))

	// Some faction information.
	variables["home_system"] = html_encode( sql_sanitize_text( home_system ))
	variables["citizenship"] = html_encode( sql_sanitize_text( citizenship ))
	variables["faction"] = html_encode( sql_sanitize_text( faction ))
	variables["religion"] = html_encode( sql_sanitize_text( religion ))

	// Jobs, uses bitflags
	variables["department"] = sanitize_integer( department.department_id, 0, 255, 0 )
	variables["roles"] = html_encode( list2params( roles ))

	// Special role selection
	variables["job_antag"] = sanitize_integer( job_antag, 0, BITFLAGS_MAX, 0 )

	// Keeps track of preferrence for not getting any wanted jobs
	variables["alternate_option"] = sanitize_integer( alternate_option, 0, BITFLAGS_MAX, 0 )

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	variables["organ_data"] = html_encode( list2params( organ_data ))

	// The default name of a job like "Medical Doctor"
	variables["player_alt_titles"] = html_encode( list2params( player_alt_titles ))

	// Flavor texts
	variables["flavor_texts_human"] = html_encode( sql_sanitize_text( flavor_texts_human ))
	variables["flavor_texts_robot"] = html_encode( sql_sanitize_text( flavor_texts_robot ))

	// Character records, these are written by the player
	variables["med_record"] = html_encode( sql_sanitize_text( med_record ))
	variables["sec_record"] = html_encode( sql_sanitize_text( sec_record ))
	variables["gen_record"] = html_encode( sql_sanitize_text( gen_record ))
	variables["exploit_record"] = html_encode( sql_sanitize_text( exploit_record ))

	// Relation to NanoTrasen
	variables["nanotrasen_relation"] = html_encode( sql_sanitize_text( nanotrasen_relation ))

	// Character disabilities
	variables["disabilities"] = sanitize_integer( disabilities, 0, BITFLAGS_MAX, 0 )

	// Location of traitor uplink
	variables["uplink_location"] = html_encode( sql_sanitize_text( uplink_location ))

	// Unique identifiers
	variables["fingerprints"] = html_encode( sql_sanitize_text( fingerprints ))
	variables["DNA"] = html_encode( sql_sanitize_text( DNA ))
	variables["unique_identifier"] = html_encode( sql_sanitize_text( unique_identifier ))

	variables["antag_data"] = html_encode( list2params( antag_data ))

	// Status effects
	variables["employment_status"] = html_encode( sql_sanitize_text( employment_status ))
	variables["felon"] = sanitize_integer( felon, 0, BITFLAGS_MAX, 0 )
	variables["prison_date"] = html_encode( list2params( prison_date ))
	variables["round_number"] = sanitize_integer( round_number, 0, 1.8446744e+19, 0 )

	var/list/names = list()
	var/list/values = list()
	for( var/name in variables )
		names += sql_sanitize_text( name )
		values += variables[name]

	establish_db_connection()
	if( !dbcon.IsConnected() )
		testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because the database wasn't connected" )
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
			testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because of an invalid sql ID" )
			return 0

	if(sql_id)
		if( names.len != values.len )
			testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because the variables length did not match the values" )
			return 0

		var/query_params = ""
		for( var/i = 1; i <= names.len; i++ )
			query_params += "[names[i]]='[values[i]]'"
			if( i != names.len )
				query_params += ","

		var/DBQuery/query_update = dbcon.NewQuery("UPDATE characters SET [query_params] WHERE ckey = '[variables["ckey"]]' AND name = '[variables["name"]]'")
		if( !query_update.Execute())
			testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because the SQL update failed" )
			return 0
	else
		var/query_names = list2text( names, "," )
		query_names += sql_sanitize_text( ", id" )

		var/query_values = list2text( values, "','" )
		query_values += "', null"

		// This needs a single quote before query_values because otherwise there will be an odd number of single quotes
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO characters ([query_names]) VALUES ('[query_values])")
		if( !query_insert.Execute() )
			testing( "SAVE CHARACTER: Didn't save [name] / ([ckey]) because the SQL insert failed" )
			return 0

	return 1

/proc/checkCharacter( var/character_name, var/ckey )
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	if( !ckey )
		return 0

	if( !character_name )
		return 0

	var/sql_ckey = ckey( ckey )
	var/sql_character_name = html_encode( character_name )

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM characters WHERE ckey = '[sql_ckey]' AND name = '[sql_character_name]'")
	if( !query.Execute() )
		return 0

	if( !query.NextRow() )
		return 0

	var/sql_id = query.item[1]

	if(!sql_id)
		return 0

	if(istext(sql_id))
		sql_id = text2num(sql_id)

	if(!isnum(sql_id))
		return 0

	return sql_id

/datum/character/proc/loadCharacter( var/character_name )
	if( !ckey )
		return 0

	if( !character_name )
		return 0

	if( !checkCharacter( character_name, ckey ))
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

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
	variables["roles"] = "roles"
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
	variables["antag_data"] = "antag_data"

	variables["employment_status"] = "text"
	variables["felon"] = "number"
	variables["prison_date"] = "prison_date"

	var/query_names = list2text( variables, "," )
	var/sql_ckey = ckey( ckey )
	var/sql_character_name = html_encode( sql_sanitize_text( character_name ))

	new_character = 0 // If we're loading from the database, we're obviously a pre-existing character
	temporary = 0

	var/DBQuery/query = dbcon.NewQuery("SELECT [query_names] FROM characters WHERE ckey = '[sql_ckey]' AND name = '[sql_character_name]'")
	if( !query.Execute() )
		return 0

	if( !query.NextRow() )
		return 0

	for( var/i = 1; i <= variables.len; i++ )
		var/value = query.item[i]

		switch( variables[variables[i]] )
			if( "text" )
				value = html_decode( sanitize_text( value, "ERROR" ))
			if( "number" )
				value = text2num( value )
			if( "params" )
				value = params2list( html_decode( value ))
				if( !value )
					value = list()
			if( "list" )
				value = text2list( html_decode( value ))
				if( !value )
					value = list()
			if( "language" )
				if( value in all_languages )
					value = all_languages[value]
				else
					value = "None"
			if( "birth_date" )
				birth_date = params2list( html_decode( value ))

				var/randomize = 0

				for( var/j in birth_date )
					if( birth_date[j] )
						birth_date[j] = text2num( birth_date[j] )
					else
						randomize = 1

				if( !birth_date || !birth_date.len == 3 )
					randomize = 1

				if( randomize )
					change_age( rand( 25, 45 ))

				calculate_age()
				continue
			if( "department" )
				LoadDepartment( text2num( value ))
				continue // Dont need to set the variable on this one
			if( "antag_data" )
				var/list/L = params2list( html_decode( value ))
				if( !L || !L.len )
					L = list( "notoriety" =  0, "persistant" = 0, "faction" = "Gorlex Marauders", "career_length" = 0 )
				for(var/V in L)
					if( V != "faction" ) // hardcode but pls go away
						L[V] = text2num( L[V] )
				value = L
			if( "prison_date" )
				prison_date = params2list( html_decode( value ))

				var/clear = 0

				for( var/j in prison_date )
					if( prison_date[j] )
						prison_date[j] = text2num( prison_date[j] )
					else
						clear = 1

				if( !prison_date || !prison_date.len == 3 )
					clear = 1

				if( clear )
					prison_date = list()

				value = prison_date
/* Disabling this for now until we find out why date proc is messing up
				if( prison_date && prison_date.len == 3 )
					var/days = daysTilDate( universe.date, prison_date )
					if( employment_status == "Active" && days >= PERMAPRISON_SENTENCE )
						employment_status = "Serving a life sentence"
*/
			if( "roles" )
				var/list/L = params2list( html_decode( value ))

				if( !L )
					L = list()

				for( var/role in L )
					switch( role )
						if( "Chemist" )
							L.Remove( "Chemist" )
							L["Scientist"] = "High"
						if( "Roboticist" )
							L.Remove( "Roboticist" )
							L["Scientist"] = "High"
						if( "Xenobiologist" )
							L.Remove( "Xenobiologist" )
							L["Senior Scientist"] = "High"
						if( "Atmospheric Technician" )
							L.Remove( "Atmospheric Technician" )
							L["Senior Engineer"] = "High"
						if( "Virologist" )
							L.Remove( "Virologist" )
							L["Senior Medical Doctor"] = "High"
						if( "Psychiatrist" )
							L.Remove( "Psychiatrist" )
							L["Medical Doctor"] = "High"
				value = L

		vars[variables[i]] = value

	return 1

/datum/character/proc/randomize_appearance( var/random_age = 0 )
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender, species)
	hair_face_style = random_facial_hair_style(gender, species)
	if(species != "Machine")
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

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old")
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
/* those darn kids and their skateboards
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)
*/

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			hair_color = rgb( red, green, blue )
		if("facial")
			hair_face_color = rgb( red, green, blue )

// Call this to change the character's age, will recalculate their birthday given an age
/datum/character/proc/change_age( var/new_age, var/age_min = AGE_MIN, var/age_max = AGE_MAX )
	new_age = max( min( round( new_age ), age_max), age_min)

	var/birth_year = game_year-new_age

	var/birth_month = text2num(time2text(world.timeofday, "MM")) - rand( 1, 12 )

	if( birth_month < 1 )
		birth_year++
		birth_month += 12

	var/birth_day = rand( 1, getMonthDays( birth_month ))

	birth_date = list( "year" = birth_year, "month" = birth_month, "day" = birth_day )
	age = calculate_age()

// Calculates the characters age from their birthdate
/datum/character/proc/calculate_age()
	var/cur_year = game_year
	var/cur_month = text2num(time2text(world.timeofday, "MM"))
	var/cur_day = text2num(time2text(world.timeofday, "DD"))

	if( !birth_date || birth_date.len < 3 )
		change_age( rand( 20, 50 )) // If we dont have a birthdate, we better get one

	var/birth_year = birth_date["year"]
	var/birth_month = birth_date["month"]
	var/birth_day = birth_date["day"]

	age = ( cur_year-birth_year )+1

	if( cur_month > birth_month )
		age++
	else if( cur_month == birth_month )
		if( cur_day >= birth_day )
			age++

	return age

// Prints the character's birthdate in a readable format
/datum/character/proc/print_birthdate()
	if( !birth_date || birth_date.len < 3 )
		calculate_age()
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

	if( job )
		clothes_s = job.make_preview_icon( backpack, GetPlayerAltTitle(job) , g)

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

/datum/character/proc/useCharacterToken( var/type, var/mob/user )
	var/num = user.client.character_tokens[type]
	if( !num || num < 1 )
		return

	switch( type )
		if( "Command" )
			if( !department || !istype( department ))
				LoadDepartment( CIVILIAN )

			roles |= getAllPromotablePositions()

		if( "Antagonist" )
			antag_data["persistant"] = 1

	num--

	user.client.character_tokens[type] = num
	user.client.saveTokens()
	saveCharacter()

/datum/character/proc/getAllPromotablePositions( var/succession_level )
	. = list()

	if( department.department_id == CIVILIAN )
		. |= department.getAllPositionNamesWithPriority()
	else
		var/datum/department/D = job_master.GetDepartment( CIVILIAN )
		. |= D.getAllPositionNamesWithPriority()
		. |= department.getAllPositionNamesWithPriority()

	for( var/role in . )
		var/datum/job/J = job_master.GetJob( role )
		if( !J )
			continue

		if( J.rank_succesion_level < succession_level )
			continue

		. -= J

	. -= getAllDemotablePositions()

	return .

/datum/character/proc/getAllDemotablePositions( var/succession_level )
	. = list()

	for( var/role in roles )
		var/datum/job/J = job_master.GetJob( role )
		if( !J )
			continue

		if( succession_level && ( J.rank_succesion_level >= succession_level ))
			continue

		. += role

	return .

/datum/character/proc/setHairColor( var/r, var/g, var/b )
	hair_color = rgb( r, g, b )

/datum/character/proc/setFacialHairColor( var/r, var/g, var/b )
	hair_face_color = rgb( r, g, b )

/datum/character/proc/setSkinTone( var/r, var/g, var/b )
	skin_tone = rgb( r, g, b )

/datum/character/proc/setSkinColor( var/r, var/g, var/b )
	skin_color = rgb( r, g, b )

/datum/character/proc/setEyeColor( var/r, var/g, var/b )
	eye_color = rgb( r, g, b )

/datum/character/proc/isPersistantAntag()
	if( !antag_data )
		return 0

	if( !antag_data["persistant"] )
		return 0

	return 1

/datum/character/proc/getAntagFaction()
	if( !isPersistantAntag() )
		return 0

	return faction_controller.get_faction(antag_data["faction"])

/datum/character/proc/canJoin()
	if( employment_status != "Active" )
		return 0

	if( prison_date && prison_date.len )
		var/days = daysTilDate( universe.date, prison_date )
		if( days > 0 )
			return 0

	return 1
