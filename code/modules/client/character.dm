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
	var/mob/living/carbon/human/char_mob
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
	var/list/roles = list( "Assistant" = "Low" ) // Roles that the player has unlocked

	// Special role selection
	var/job_antag = 0

	// Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = RETURN_TO_LOBBY

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	// The default name of a job like "Medical Doctor"
	var/list/player_alt_titles = new()

	// Flavor texts
	var/flavor_texts_human
	var/flavor_texts_robot

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

	/*
	The var below stores antag data, all current indexes are
		notoriety	-	How infamous this antag is, the more infamous, the better contracts they can acquire
		persistant 	-	Is this character a persistant antag? If not, none of the following indexes will be used

	/// - persistant antag variables - ///
		faction		-	Which syndicate faction is this antag a member of?
		dismissed	-	Has this player been dismissed from the syndicate?
	*/
	var/list/antag_data = list("notoriety" =  0, "persistant" = 0, "faction" = "Gorlex Marauders", "career_length" = 0)

	// A few status effects
	var/employment_status = "Active" // Is this character employed and alive or gone for good?
	var/felon = 0 // Is this character a convicted felon?
	var/list/prison_date // The date that they get released from prison

	var/round_number = 0 // When was this character last played?

	var/datum/browser/menu

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
	var/temporary = 1 // Is this character only for this round?
