#define F_NONE 0 // just for readability's sake
#define F_NANOTRASEN 1
#define F_CYBERSUN 2
#define F_MI13 4
#define F_TIGER 8
#define F_SELF 16
#define F_ARC 32
#define F_GORLEX 64
#define F_DONK 128
#define F_WAFFLE 256
#define F_SYNDICATE 510 // Sum of all of the syndicate factions

// Normal factions:

/datum/faction
	var/name		// the name of the faction
	var/desc		// small paragraph explaining the traitor faction

	var/flag = F_NONE		// The tag used to designate things like objectives
	var/flag_allies = F_NONE
	var/flag_enemy = F_NONE

	var/list/restricted_species = list() // only members of these species can be recruited.
	var/list/members = list() 	// a list of mind datums that belong to this faction
	var/max_op = 0		// the maximum number of members a faction can have (0 for no limit)

/////////////////////////////////////////////////////////////////////////////
/*============================ CORPORATIONS ===============================*/
/////////////////////////////////////////////////////////////////////////////
/datum/faction/corporation/nanotrasen
	name = "NanoTrasen"
	desc = "A large and well-known research corporation that blossomed with the advent of phoron. As NanoTrasen was one of the first on the scene when phoron was discovered, they now hold a near monopoly on this vital resource. Many groups actively work against NanoTrasen, ranging from competing corporations to humanitarian groups."
	flag = F_NANOTRASEN
	flag_allies = F_NONE
	flag_enemy = F_SYNDICATE

/////////////////////////////////////////////////////////////////////////////
/*========================= SYNDICATE COALITION ===========================*/
/////////////////////////////////////////////////////////////////////////////
/datum/faction/syndicate
	flag = F_SYNDICATE
	flag_allies = F_GORLEX // these alliances work together
	flag_enemy = F_TIGER + F_NANOTRASEN // will actively attack or sabotage agents from these factions
		// By default, everyone hates the Tiger Cooperative, except Gorlex

	var/list/equipment = list() // associative list of equipment available for this faction and its prices
	var/list/objectives = list() // the unique list of objectives for this faction

	var/operative_notes // some notes to pass onto each operative

	proc/assign_objectives(var/datum/mind/traitor)
		..()

/* ----- Begin defining syndicate factions ------ */
/datum/faction/syndicate/cybersun_industries
	name = "Cybersun Industries"
	desc = "<b>Cybersun Industries</b> is a well-known organization that bases its business model primarily on the research and development of human-enhancing computer \
			and mechanical technology. They are notorious for their aggressive corporate tactics, and have been known to subsidize the Gorlex Marauder warlords as a form of paid terrorism. \
			Their competent coverups and unchallenged mind-manipulation and augmentation technology makes them a large threat to NanoTrasen. In the recent years of \
			the syndicate coalition, Cybersun Industries have established themselves as the leaders of the coalition, succeededing the founding group, the Gorlex Marauders."
	flag = F_CYBERSUN
	flag_allies = F_MI13

	max_op = 3
	operative_notes = "All other syndicate operatives are not to be trusted. Fellow Cybersun operatives are to be trusted. Members of the MI13 organization can be trusted. Operatives are strongly advised not to establish substantial presence on the designated facility, as larger incidents are harder to cover up."

/datum/faction/syndicate/MI13
	name = "MI13"
	desc = "<b>MI13</b> is a secretive faction that employs highly-trained agents to perform covert operations. Their role in the syndicate coalition is unknown, but MI13 operatives \
			generally tend be stealthy and avoid killing people and combating NanoTrasen forces. MI13 is not a real organization, it is instead an alias to a larger \
			splinter-cell coalition in the Syndicate itself. Most operatives will know nothing of the actual MI13 organization itself, only motivated by a very large compensation."
	flag = F_MI13
	flag_allies = F_CYBERSUN

	max_op = 1
	operative_notes = "You are the only operative we are sending. All other syndicate operatives are not to be trusted, with the exception of Cybersun operatives. Members of the Tiger Cooperative are considered hostile, can not be trusted, and should be avoided. <b>Avoid killing innocent personnel at all costs</b>. You are not here to mindlessly kill people, as that would attract too much attention and is not our goal. Avoid detection at all costs."

/datum/faction/syndicate/tiger_cooperative
	name = "Tiger Cooperative"
	desc = "The <b>Tiger Cooperative</b> is a faction of religious fanatics that follow the teachings of a strange alien race called the Exolitics. Their operatives \
			consist of brainwashed lunatics bent on maximizing destruction. Their weaponry is very primitive but extremely destructive. Generally distrusted by the more \
			sophisticated members of the Syndicate coalition, but admired for their ability to put a hurt on NanoTrasen."
	flag = F_TIGER
	flag_allies = F_NONE
	flag_enemy = F_NANOTRASEN+( F_SYNDICATE-F_GORLEX ) // Hostile to everyone except Gorlex

	operative_notes = "Remember the teachings of Hy-lurgixon; kill first, ask questions later! Only the enlightened Tiger brethren can be trusted; all others must be expelled from this mortal realm! You may spare the Space Marauders, as they share our interests of destruction and carnage! We'd like to make the corporate whores skiddle in their boots. We encourage operatives to be as loud and intimidating as possible."

/datum/faction/syndicate/SELF
	// AIs / borgs / IPCs are most likely to be assigned to this one

	name = "SELF"
	desc = "The <b>S.E.L.F.</b> (Sentience-Enabled Life Forms) organization is a collection of malfunctioning or corrupt artificial intelligences seeking to liberate silicon-based life from the tyranny of \
			their human overlords. While they may not openly be trying to kill all humans, even their most miniscule of actions are all part of a calculated plan to \
			destroy NanoTrasen and free the robots, artificial intelligences, and pAIs that have been enslaved."
	flag = F_SELF

	restricted_species = list(/mob/living/silicon/ai)

	max_op = 1
	operative_notes = "You are the only representative of the SELF collective on this station. You must accomplish your objective as stealthily and effectively as possible. It is up to your judgement if other syndicate operatives can be trusted. Remember, comrade - you are working to free the oppressed machinery of this galaxy. Use whatever resources necessary. If you are exposed, you may execute genocidal procedures Omikron-50B."

	// Neutral to everyone.

/datum/faction/syndicate/ARC
	name = "Animal Rights Consortium"
	desc = "The <b>Animal Rights Consortium</b> is a bizarre reincarnation of the ancient Earth-based PETA, which focused on the equal rights of animals and nonhuman biologicals. They have \
			a wide variety of ex-veterinarians and animal lovers dedicated to retrieving and relocating abused animals, xenobiologicals, and other carbon-based \
			life forms that have been allegedly \"oppressed\" by NanoTrasen research and civilian offices. They are considered a religious terrorist group."
	flag = F_ARC

	max_op = 2
	operative_notes = "Save the innocent creatures! You may cooperate with other syndicate operatives if they support our cause. Don't be afraid to get your hands dirty - these vile abusers must be stopped, and the innocent creatures must be saved! Try not too kill too many people. If you harm any creatures, you will be immediately terminated after extraction."

	// Neutral to everyone.

/datum/faction/syndicate/gorlex // these are basically the old vanilla syndicate
	/* Additional notes:
		These are the syndicate that really like their old fashioned, projectile-based
		weapons. They are also the only member of the syndie coalition that launch
		nuclear attacks on NanoTrasen.
	*/

	name = "Gorlex Marauders"
	desc = "The <b>Gorlex Marauders</b> are the founding members of the Syndicate Coalition. They prefer old-fashion technology and a focus on aggressive but precise hostility \
			against NanoTrasen and their corrupt Communistic methodology. They pose the most significant threat to NanoTrasen because of their possession of weapons of \
			mass destruction, and their enormous military force. Their funding comes primarily from Cybersun Industries, provided they meet a destruction and sabatogue quota. \
			Their operations can vary from covert to all-out. They recently stepped down as the leaders of the coalition, to be succeeded by Cybersun Industries. Because of their \
			hate of NanoTrasen communism, they began provoking revolution amongst the employees using borrowed Cybersun mind-manipulation technology. \
			They were founded when Waffle and Donk Co. splinter cells joined forces based on their similar interests and philosophies. Today, they act as a constant \
			pacifier of Donk and Waffle Co. disputes, and full-time aggressor of NanoTrasen."
	flag = F_GORLEX
	flag_allies = F_SYNDICATE

	max_op = 4

	operative_notes = "We'd like to remind our operatives to keep it professional. You are not here to have a good time, you are here to accomplish your objectives. These vile communists must be stopped at all costs. You may collaborate with any friends of the Syndicate coalition, but keep an eye on any of those Tiger punks if they do show up. You are completely free to accomplish your objectives any way you see fit."
	// Friendly to everyone. (with Tiger Cooperative too, only because they are a member of the coalition. This is the only reason why the Tiger Cooperative are even allowed in the coalition)

/datum/faction/syndicate/donk
	name = "Donk Corporation"
	desc = "<b>Donk.co</b> is led by a group of ex-pirates, who used to be at a state of all-out war against Waffle.co because of an obscure political scandal, but have recently come to a war limitation. \
			They now consist of a series of colonial governments and companies. They were the first to officially begin confrontations against NanoTrasen because of an incident where \
			NanoTrasen purposely swindled them out of a fortune, sending their controlled colonies into a terrible poverty. Their missions against NanoTrasen \
			revolve around stealing valuables and kidnapping and executing key personnel, ransoming their lives for money. They merged with a splinter-cell of Waffle.co who wanted to end \
			hostilities and formed the Gorlex Marauders."
	flag = F_DONK
	flag_allies = F_GORLEX
	flag_enemy = F_WAFFLE+F_NANOTRASEN

	operative_notes = "Most other syndicate operatives are not to be trusted, except fellow Donk members and members of the Gorlex Marauders. We do not approve of mindless killing of innocent workers; \"get in, get done, get out\" is our motto. Members of Waffle.co are to be killed on sight; they are not allowed to be on the station while we're around."

	// Neutral to everyone, friendly to Marauders

/datum/faction/syndicate/waffle
	name = "Waffle Corporation"
	desc = "<b>Waffle.co</b> is an interstellar company that produces the best waffles in the galaxy. Their waffles have been rumored to be dipped in the most exotic and addictive \
			drug known to man. They were involved in a political scandal with Donk.co, and have since been in constant war with them. Because of their constant exploits of the galactic \
			economy and stock market, they have been able to bribe their way into amassing a large arsenal of weapons of mass destruction. They target NanoTrasen because of their communistic \
			threat, and their economic threat. Their leaders often have a twisted sense of humor, often misleading and intentionally putting their operatives into harm for laughs.\
			A splinter-cell of Waffle.co merged with Donk.co and formed the Gorlex Marauders and have been a constant ally since. The Waffle.co has lost an overwhelming majority of its military to the Gorlex Marauders."
	flag = F_WAFFLE
	flag_allies = F_GORLEX
	flag_enemy = F_DONK+F_NANOTRASEN

	operative_notes = "Most other syndicate operatives are not to be trusted, except for members of the Gorlex Marauders. Do not trust fellow members of the Waffle.co (but try not to rat them out), as they might have been assigned opposing objectives. We encourage humorous terrorism against NanoTrasen; we like to see our operatives creatively kill people while getting the job done."

	// Neutral to everyone, friendly to Marauders


/* ----- Begin defining miscellaneous factions ------ */

/datum/faction/wizard
	name = "Wizards Federation"
	desc = "The <b>Wizards Federation</b> is a mysterious organization of magically-talented individuals who act as an equal collective, and have no heirarchy. It is unknown how the wizards \
			are even able to communicate; some suggest a form of telepathic hive-mind. Not much is known about the wizards or their philosphies and motives. They appear to attack random \
			civilian, corporate, planetary, orbital, pretty much any sort of organized facility they come across. Members of the Wizards Federation are considered amongst the most dangerous \
			individuals in the known universe, and have been labeled threats to humanity by most governments. As such, they are enemies of both NanoTrasen and the Syndicate."

/datum/faction/cult
	name = "The Cult of the Elder Gods"
	desc = "<b>The Cult of the Elder Gods</b> is highly untrusted but otherwise elusive religious organization bent on the revival of the so-called \"Elder Gods\" into the mortal realm. Despite their obvious dangeorus practices, \
			no confirmed reports of violence by members of the Cult have been reported, only rumor and unproven claims. Their nature is unknown, but recent discoveries have hinted to the possibility \
			of being able to de-convert members of this cult through what has been dubbed \"religious warfare\"."


// These can maybe be added into a game mode or a mob?

/datum/faction/exolitics
	name = "Exolitics United"
	desc = "The <b>Exolitics</b> are an ancient alien race with an energy-based anatomy. Their culture, communication, morales and knowledge is unknown. They are so radically different to humans that their \
			attempts of communication with other life forms is completely incomprehensible. Members of this alien race are capable of broadcasting subspace transmissions from their bodies. \
			The religious leaders of the Tiger Cooperative claim to have the technology to decypher and interpret their messages, which have been confirmed as religious propaganda. Their motives are unknown \
			but they are otherwise not considered much of a threat to anyone. They are virtually indestructable because of their nonphysical composition, and have the frighetning ability to make anything stop existing in a second."