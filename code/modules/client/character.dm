var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = IS_MODE_COMPILED("traitor"),             // 0
	"operative" = IS_MODE_COMPILED("nuclear"),           // 1
	"changeling" = IS_MODE_COMPILED("changeling"),       // 2
	"wizard" = IS_MODE_COMPILED("wizard"),               // 3
	"malf AI" = IS_MODE_COMPILED("malfunction"),         // 4
	"revolutionary" = IS_MODE_COMPILED("revolution"),    // 5
	"alien candidate" = 1, //always show                 // 6
	"positronic brain" = 1,                              // 7
	"cultist" = IS_MODE_COMPILED("cult"),                // 8
	"infested monkey" = IS_MODE_COMPILED("monkey"),      // 9
	"ninja" = "true",                                    // 10
	"vox raider" = IS_MODE_COMPILED("heist"),            // 11
	"diona" = 1,                                         // 12
	"mutineer" = IS_MODE_COMPILED("mutiny"),             // 13
	"pAI candidate" = 1, // -- TLE                       // 14
)

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/character
	var/name							//our character's name
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/blood_type = "A+"				//blood type (not-chooseable)
	var/underwear = 1					//underwear type
	var/undershirt = 1					//undershirt type
	var/backpack = 2					//backpack type
	var/hair_style = "Bald"				//Hair type
	var/hair_face_style = "Shaved"		//Facial hair type
	var/hair_color						//Hair color
	var/hair_face_color					//Face hair color
	var/skin_tone						//Skin tone
	var/skin_color						//Skin color
	var/eye_color						//Eye color
	var/species = "Human"               //Species datum to use.
	var/species_preview                 //Used for the species selection window.
	var/language = "None"				//Secondary language
	var/list/gear						//Custom/fluff item loadout.

	// Some faction information.
	var/home_system = "Unset"           //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.

	// Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

	// Jobs, uses bitflags
	var/job_civilian_high = 0
	var/job_civilian_med = 0
	var/job_civilian_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	// Special role selection
	var/job_antag = 0

	// Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 0

	// Skills
	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	// the default name of a job like "Medical Doctor"
	var/list/player_alt_titles = new()

	var/list/flavor_texts = list()
	var/list/flavour_texts_robot = list()

	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/disabilities = 0

	var/nanotrasen_relation = "Neutral"

	var/uplinklocation = "PDA"

/datum/character/New(client/C)
	blood_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

	gender = pick(MALE, FEMALE)
	name = random_name(gender,species)

	gear = list()

/datum/character/proc/copy_to(mob/living/carbon/human/character, safety = 0)
	if(config.humans_need_surnames)
		var/firstspace = findtext(name, " ")
		var/name_length = length(name)
		if(!firstspace)	//we need a surname
			name += " [pick(last_names)]"
		else if(firstspace == name_length)
			name += "[pick(last_names)]"

	character.real_name = name
	character.name = character.real_name
	if(character.dna)
		character.dna.real_name = character.real_name

	character.flavor_texts["general"] = flavor_texts["general"]

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.gender = gender
	character.age = age
	character.b_type = blood_type

	var/list/eyes_rgb = ReadRGB( hair_face_color )
	if( eyes_rgb && eyes_rgb.len > 2 ) // if there's a skin color selected
		character.r_eyes = eyes_rgb[1]
		character.g_eyes = eyes_rgb[2]
		character.b_eyes = eyes_rgb[3]
	else
		character.r_eyes = rand( 0, 255 )
		character.g_eyes = rand( 0, 255 )
		character.b_eyes = rand( 0, 255 )

	var/list/hair_rgb = ReadRGB( hair_face_color )
	if( hair_rgb && hair_rgb.len > 2 ) // if there's a skin color selected
		character.r_hair = hair_rgb[1]
		character.g_hair = hair_rgb[2]
		character.b_hair = hair_rgb[3]
	else
		character.r_hair = rand( 0, 255 )
		character.g_hair = rand( 0, 255 )
		character.b_hair = rand( 0, 255 )

	var/list/hair_face_rgb = ReadRGB( hair_face_color )
	if( hair_face_rgb && hair_face_rgb.len > 2 ) // if there's a skin color selected
		character.r_facial = hair_face_rgb[1]
		character.g_facial = hair_face_rgb[2]
		character.b_facial = hair_face_rgb[3]
	else
		character.r_facial = rand( 0, 255 )
		character.g_facial = rand( 0, 255 )
		character.b_facial = rand( 0, 255 )

	var/list/skin_rgb = ReadRGB( skin_color )
	if( skin_rgb && skin_rgb.len > 2 ) // if there's a skin color selected
		character.r_skin = skin_rgb[1]
		character.g_skin = skin_rgb[2]
		character.b_skin = skin_rgb[3]
	else
		character.r_skin = rand( 0, 255 )
		character.g_skin = rand( 0, 255 )
		character.b_skin = rand( 0, 255 )

	character.skin_tone = skin_tone

	character.h_style = hair_style
	character.f_style = hair_face_style

	character.home_system = home_system
	character.citizenship = citizenship
	character.personal_faction = faction
	character.religion = religion

	character.skills = skills
	character.used_skillpoints = used_skillpoints

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
	character.underwear = underwear

	if(undershirt > undershirt_t.len || undershirt < 1)
		undershirt = 0
	character.undershirt = undershirt

	if(backpack > 4 || backpack < 1)
		backpack = 1 //Same as above
	character.backpack = backpack

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.gender = MALE

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

