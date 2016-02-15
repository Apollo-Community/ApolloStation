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

var/list/all_characters = list() // A list of all loaded characters

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/character
	var/ckey

	// Basic information
	var/name							//our character's name
	var/gender = MALE					//gender of character (well duh)
	var/age = AGE_DEFAULT				//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/blood_type = "A+"				//blood type (not-chooseable)

	// Default clothing
	var/underwear = 1					// underwear type
	var/undershirt = 1					// undershirt type
	var/backpack = 2					// backpack type

	// Cosmetic features
	var/hair_style = "Bald"				// Hair type
	var/hair_face_style = "Shaved"		// Facial hair type
	var/hair_color = "#000000"			// Hair color
	var/hair_face_color	= "#000000"		// Face hair color

	var/skin_tone = SKIN_TONE_DEFAULT	// Skin tone
	var/skin_color = "#000000"			// Skin color

	var/eye_color = "#000000"			// Eye color

	// Character species
	var/species = "Human"               // Species to use.

	// Secondary language
	var/additional_language = "None"

	// Custom spawn gear
	var/list/gear

	// Some faction information.
	var/home_system = "Unset"           //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.

	// Job vars, these are used in the job selection screen and hiring computer
	var/datum/department/department
	var/roles = list( "Assistant" = "Low" ) // Roles that the player has unlocked

	// Special role selection
	var/job_antag = 0

	// Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 0

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	// The default name of a job like "Medical Doctor"
	var/list/player_alt_titles = new()

	// Flavor texts
	var/flavor_texts_human
	var/flavor_texts_robot

	// Character notes, these are written by other people. Format is list( datetime = note )
	var/med_notes = list()
	var/sec_notes = list()
	var/gen_notes = list()

	// Character records, these are written by the player
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""

	// Relation to NanoTrasen
	var/nanotrasen_relation = "Neutral"

	// Character disabilities
	var/disabilities = 0

	// Location of traitor uplink
	var/uplink_location = "PDA"

	var/DNA
	var/fingerprints
	var/unique_identifier

	var/list/birth_date = list()

	// Skills
	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null
	var/species_preview   // Used for the species selection window.

	var/new_character = 1 // Is this a new character?

/datum/character/New( var/key, var/new_char = 1 )
	ckey = ckey( key )

	blood_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

	gender = pick(MALE, FEMALE)
	name = random_name(gender,species)

	gear = list()

	DNA = md5( "DNA[name][blood_type][gender][eye_color][time2text(world.timeofday,"hh:mm")]" )
	fingerprints = md5( DNA )
	unique_identifier = md5( fingerprints )

	new_character = new_char

	change_age( 30 )

	if( !department )
		LoadDepartment( CIVILIAN )

	all_characters += src

/datum/character/Destroy()
	all_characters -= src

	..()

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

	character.character = src

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

