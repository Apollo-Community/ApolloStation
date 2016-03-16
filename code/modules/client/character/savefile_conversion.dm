// USE THESE PROCS IF YOU WANT TO CONVERT SAVEFILES TO SQL DATABASE SAVES

/proc/convert_savefiles_to_SQL()
	var/DBQuery/query = dbcon.NewQuery( "SELECT ckey FROM player" )
	query.Execute()

	while( query.NextRow() )
		var/ckey = query.item[1]
		convert_ckey_savefile_to_SQL( ckey )

	convert_whitelist_to_tokens()

/client/verb/convert_savefiles()
	set name = "Convert Savefiles"
	set category = "OOC"
	set desc = "Convert your text savefiles into SQL savefiles."

	var/input_ckey = input( usr, "Input your ckey, with underscores and spaces included:", "Savefile Conversion" )  as text|null

	if( !input_ckey )
		return
	if( convert_ckey_savefile_to_SQL( input_ckey, usr ))
		usr << "Savefiles successfully converted for [input_ckey]!"
		src.verbs -= /client/verb/convert_savefiles
	else
		usr << "Failed to convert savefiles for [input_ckey]"

/proc/convert_ckey_savefile_to_SQL( var/ckey, var/mob/user = null )
	var/path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/preferences.sav"
	if( !fexists( path ))
		if( !user )
			world << "[ckey]'s character saves do not exist!"
		else
			user << "[ckey]'s character saves do not exist!"
		return 0

	var/list/characters = loadCharactersFromSavefile( path, ckey )
	if( !characters || !characters.len )
		if( !user )
			world << "[ckey]'s character saves could not be converted!"
		else
			user << "[ckey]'s character saves could not be converted!"
		return 0

	if( !user )
		world << "[characters.len] characters found for [ckey]"
	else
		user << "[characters.len] characters found for [ckey]"

	for( var/datum/character/character in characters )
		character.saveCharacter()

	return 1

/proc/loadCharactersFromSavefile( var/path, var/ckey )
	if(!path)
		world << "Bad path!"
		return 0
	if(!fexists(path))
		world << "Path does not exist!"
		return 0

	var/savefile/S = new /savefile(path)
	if(!S)
		world << "Save file could not be read!"
		return 0

	S.cd = "/"

	var/list/characters = list()
	var/list/directories = S.dir

	for( var/directory in directories )
		if( !findtext( directory, "character" ))
			continue

		S.cd = "/"
		S.cd = "[directory]"

		var/datum/character/C = new( ckey, 0, 0 )

		var/age = 30
		//Character
		S["real_name"]			>> C.name
		S["gender"]				>> C.gender
		S["age"]				>> age
		S["species"]			>> C.species
		S["language"]			>> C.additional_language
		S["spawnpoint"]			>> C.spawnpoint

		C.change_age( age )

		//colors to be consolidated into hex strings (requires some work with dna code)
		var/r_hair
		var/g_hair
		var/b_hair

		var/r_facial
		var/g_facial
		var/b_facial

		var/r_skin
		var/g_skin
		var/b_skin

		var/r_eyes
		var/g_eyes
		var/b_eyes

		S["hair_red"]			>> r_hair
		S["hair_green"]			>> g_hair
		S["hair_blue"]			>> b_hair
		C.hair_color = rgb( r_hair, g_hair, b_hair )

		S["facial_red"]			>> r_facial
		S["facial_green"]		>> g_facial
		S["facial_blue"]		>> b_facial
		C.hair_face_color = rgb( r_facial, g_facial, b_facial )

		S["skin_tone"]			>> C.skin_tone
		S["skin_red"]			>> r_skin
		S["skin_green"]			>> g_skin
		S["skin_blue"]			>> b_skin
		C.skin_color = rgb( r_skin, g_skin, b_skin )

		S["hair_style_name"]	>> C.hair_style
		S["facial_style_name"]	>> C.hair_face_style
		S["eyes_red"]			>> r_eyes
		S["eyes_green"]			>> g_eyes
		S["eyes_blue"]			>> b_eyes
		C.eye_color = rgb( r_eyes, g_eyes, b_eyes )

		S["underwear"]			>> C.underwear
		S["undershirt"]			>> C.undershirt
		S["backbag"]			>> C.backpack
		C.blood_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

		//Alternate job titles
		C.alternate_option = RETURN_TO_LOBBY

		//Flavour Text
		S["flavor_texts_general"]	>> C.flavor_texts_human

		//Flavour text for robots.
		S["flavour_texts_robot_Default"] >> C.flavor_texts_robot

		//Miscellaneous
		S["med_record"]			>> C.med_record
		S["sec_record"]			>> C.sec_record
		S["gen_record"]			>> C.gen_record
		S["be_special"]			>> C.job_antag
		S["disabilities"]		>> C.disabilities
		S["player_alt_titles"]	>> C.player_alt_titles
		S["organ_data"]			>> C.organ_data
		S["gear"]				>> C.gear
		S["home_system"] 		>> C.home_system
		S["citizenship"] 		>> C.citizenship
		S["faction"] 			>> C.faction
		S["religion"] 			>> C.religion

		S["nanotrasen_relation"] >> C.nanotrasen_relation

		S["uplinklocation"] >> C.uplink_location
		S["exploit_record"]	>> C.exploit_record

		if(isnull(C.species) || !(C.species in all_species))
			C.species = "Human"

		if(!C.name) continue // If even the name couldn't be read, the character is a lost cause
		if(isnull(C.additional_language)) C.additional_language = "None"
		if(isnull(C.spawnpoint)) C.spawnpoint = "Arrivals Shuttle"
		if(isnull(C.nanotrasen_relation)) C.nanotrasen_relation = initial(C.nanotrasen_relation)

		if(isnull(C.disabilities)) C.disabilities = 0
		if(!C.player_alt_titles) C.player_alt_titles = new()
		if(!C.organ_data) C.organ_data = list()
		if(!C.gear) C.gear = list()
		if(!C.hair_style) C.hair_style = "Bald"

		if(!C.home_system) C.home_system = "Unset"
		if(!C.citizenship) C.citizenship = "None"
		if(!C.faction)     C.faction =     "None"
		if(!C.religion)    C.religion =    "None"

		characters += C

	return characters
