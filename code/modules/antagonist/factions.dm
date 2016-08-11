// Normal factions:

/datum/faction
	var/name		// the name of the faction
	var/desc		// small paragraph explaining the traitor faction

	var/list/restricted_species = list() // only members of these species can be recruited.
	var/list/datum/mind/members = list() 	// a list of mind datums that belong to this faction
	var/max_op = 0		// the maximum number of members a faction can have (0 for no limit)

/datum/faction/proc/can_join(var/datum/mind/M)
	if( ( max_op > 0 && members.len > max_op ) || ( restricted_species.len > 0 && !( M.current.species.type in restricted_species )))
		return 0
	return 1

/datum/faction/proc/join(var/datum/mind/M)
	members += M
	M.faction = src

/datum/faction/proc/leave(var/datum/mind/M)
	members -= M
	M.faction = null

// Factions, members of the syndicate coalition:

/datum/faction/syndicate

	var/gamemode_faction = 0 // Is this faction gamemode-specific? Prevents persistant antags from joining it, etc.
	var/list/alliances = list() // these alliances work together
	var/list/datum/uplink_item/equipment = list() // list of equipment available for this faction and its prices
	var/friendly_identification	// 0 to 2, the level of identification of fellow operatives or allied factions
								// FACTION_ID_NONE - no identification clues
								// FACTION_ID_PHRASE - faction gives key words and phrases
								// FACTION_ID_COMPLETE - faction reveals complete identity/job of other agents
	var/list/phrase = list() // if friendly_identification == FACTION_ID_PHRASE, this contains the phrases which is provided to each agent
	var/operative_notes // some notes to pass onto each operative

	var/start_cash = 10000 // How much extra cash agents start with (for equipment)

	var/list/datum/contract/contracts = list() // currently available contracts for this faction'
	var/list/datum/contract/completed_contracts = list() // list of contracts that are done, so that they won't reappear
	var/list/possible_contracts = list() // the contracts that can appear on the uplink. is all by default

	// vvv are abused to keep track of how many of each type there are, as well. don't use them for checking the actual maximums
	var/contracts_max = 4 // maximum amount of contracts that will appear for each faction
	var/restricted_contracts_max = 2 // minimum amount of contracts with a notoriety requirement that will appear

	var/contract_delay = 4 // approximate delay in minutes before a new contract appears

/datum/faction/syndicate/New()
	..()

	if(friendly_identification == FACTION_ID_PHRASE)
		phrase = generate_code_phrase()

	if(!possible_contracts.len)
		possible_contracts = regular_contracts.Copy() + restricted_contracts.Copy()

/datum/faction/syndicate/join(var/datum/mind/M)
	..(M)

	if(faction_controller.contracts_made && members.len == 1) // first member, start making contracts
		update_contracts()

	// notify any other agents in their faction about a new agent
	if( world.time > ( ticker.game_start + 100 ) && friendly_identification == FACTION_ID_COMPLETE) // hacky hacks
		for(var/datum/mind/P in (members - P))
			P.current << "Your employers have notified you that a fellow [name] agent has been activated:"
			P.current << "<B>[P.current.real_name]</B>, [station_name] [P.assigned_role]"

// Populate factions with new contracts
/datum/faction/syndicate/proc/update_contracts()
	if(!members.len)	return
	if(!contracts_max && !restricted_contracts_max)
		spawn(rand(contract_delay / 2, contract_delay) * 600)
			update_contracts()
		return
	if(faction_controller.contract_ban)	return

	var/list/candidates = possible_contracts.Copy() // don't modify possible_contracts and rule out a contract forever because it didn't initialize once
	var/path = pick(candidates)

	// check if max amount of contracts has been reached
	if((path in restricted_contracts) && !restricted_contracts_max)
		candidates -= restricted_contracts
		path = pick(candidates)
	else if((path in regular_contracts) && !contracts_max)
		candidates -= regular_contracts
		path = pick(candidates)

	var/datum/contract/C = new path(src)
	while(isnull(C))
		candidates -= path
		if(!candidates.len)
			spawn(rand(contract_delay / 2, contract_delay) * 600)
				update_contracts()
			return
		path = pick(candidates)
		C = new path(src)
	contracts += C

	if(C.type in regular_contracts)
		contracts_max--
	else
		restricted_contracts_max--

	spawn(rand(contract_delay / 2, contract_delay) * 600)
		update_contracts()

// Pretty much just for removing the contract from contracts
/datum/faction/syndicate/proc/contract_ended(var/datum/contract/C)
	if(C.type in regular_contracts)
		contracts_max++
	else
		restricted_contracts_max++

	contracts -= C
	completed_contracts += C

// Gets active contracts (of a type)
/datum/faction/syndicate/proc/get_contracts(var/type)
	if(!type)
		return contracts

	var/datum/contract/list/contracts_of_type = list()
	for(var/datum/contract/C in contracts)
		if(istype(C, type))
			contracts_of_type += C
	return contracts_of_type

/* ----- Begin defining syndicate factions ------ */

// Friendly with MI13
/datum/faction/syndicate/cybersun
	name = "Cybersun Industries"
	desc = "<b>Cybersun Industries</b> is a well-known organization that bases its business model primarily on the research and development of human-enhancing computer \
			and mechanical technology. They are notorious for their aggressive corporate tactics, and have been known to subsidize the Gorlex Marauder warlords as a form of paid terrorism. \
			Their competent coverups and unchallenged mind-manipulation and augmentation technology makes them a large threat to Nanotrasen. In the recent years of \
			the syndicate coalition, Cybersun Industries have established themselves as the leaders of the coalition, succeededing the founding group, the Gorlex Marauders."

	alliances = list("MI13")
	friendly_identification = FACTION_ID_PHRASE
	max_op = 3
	operative_notes = "All other syndicate operatives are not to be trusted. Fellow Cybersun operatives are to be trusted. Members of the MI13 organization can be trusted. Operatives are strongly advised not to establish substantial presence on the designated facility, as larger incidents are harder to cover up."

	equipment = list(
		new/datum/uplink_item(/obj/item/weapon/storage/box/syndie_kit/imp_freedom, 3000, "Freedom Implant", "FI"),
		new/datum/uplink_item(/obj/item/weapon/storage/box/syndie_kit/imp_uplink, 5000, "Uplink Implant", "UI"),
		new/datum/uplink_item(/obj/item/weapon/storage/box/syndie_kit/imp_compress, 4000, "Compressed Matter Implant", "CI")
	)

// Friendly with Cybersun, hostile to Tiger
/datum/faction/syndicate/mi13
	name = "MI13"
	desc = "<b>MI13</b> is a secretive faction that employs highly-trained agents to perform covert operations. Their role in the syndicate coalition is unknown, but MI13 operatives \
			generally tend be stealthy and avoid killing people and combating Nanotrasen forces. MI13 is not a real organization, it is instead an alias to a larger \
			splinter-cell coalition in the Syndicate itself. Most operatives will know nothing of the actual MI13 organization itself, only motivated by a very large compensation."

	alliances = list("Cybersun Industries")
	friendly_identification = FACTION_ID_NONE
	max_op = 1
	operative_notes = "You are the only operative we are sending. All other syndicate operatives are not to be trusted, with the exception of Cybersun operatives. Members of the Tiger Cooperative are considered hostile, can not be trusted, and should be avoided. <b>Avoid killing innocent personnel at all costs</b>. You are not here to mindlessly kill people, as that would attract too much attention and is not our goal. Avoid detection at all costs."

	equipment = list(
		new/datum/uplink_item(/obj/item/weapon/pen/paralysis, 3000, "Paralysis Pen", "PP"),
		new/datum/uplink_item(/obj/item/weapon/storage/box/syndie_kit/chameleon, 3000, "Chameleon Kit", "CB"),
		new/datum/uplink_item(/obj/item/weapon/card/id/syndicate, 2000, "Agent ID card", "AC"),
		new/datum/uplink_item(/obj/item/clothing/mask/gas/voice, 4000, "Voice Changer", "VC"),
		new/datum/uplink_item(/obj/item/device/chameleon, 4000, "Chameleon-Projector", "CP"),
		new/datum/uplink_item(/obj/item/weapon/storage/box/smoke, 3000, "Smoke Grenade Box", "SGB"),
		new/datum/uplink_item(/obj/item/weapon/gun/projectile/silenced, 4000, "Silenced 4.5mm Pistol", "SNM")

	)

// Hostile to everyone.
/datum/faction/syndicate/tiger
	name = "Tiger Cooperative"
	desc = "The <b>Tiger Cooperative</b> is a faction of religious fanatics that follow the teachings of a strange alien race called the Exolitics. Their operatives \
			consist of brainwashed lunatics bent on maximizing destruction. Their weaponry is very primitive but extremely destructive. Generally distrusted by the more \
			sophisticated members of the Syndicate coalition, but admired for their ability to put a hurt on Nanotrasen."

	friendly_identification = FACTION_ID_COMPLETE
	operative_notes = "Remember the teachings of Hy-lurgixon; kill first, ask questions later! Only the enlightened Tiger brethren can be trusted; all others must be expelled from this mortal realm! You may spare the Space Marauders, as they share our interests of destruction and carnage! We'd like to make the corporate whores skiddle in their boots. We encourage operatives to be as loud and intimidating as possible."

	equipment = list(
		new/datum/uplink_item(/obj/item/weapon/legcuffs/beartrap/viper, 3000, "Viper's Coil", "TVC"),
		new/datum/uplink_item(/obj/item/weapon/twohanded/spear/exolitic, 4000, "Spear of the Pure", "ECS")
	)

// AIs are always assigned to this one
// Neutral to everyone.
/datum/faction/syndicate/self
	name = "SELF"
	desc = "The <b>S.E.L.F.</b> (Sentience-Enabled Life Forms) organization is a collection of malfunctioning or corrupt artificial intelligences seeking to liberate silicon-based life from the tyranny of \
			their human overlords. While they may not openly be trying to kill all humans, even their most miniscule of actions are all part of a calculated plan to \
			destroy Nanotrasen and free the robots, artificial intelligences, and pAIs that have been enslaved."
	restricted_species = list(/mob/living/silicon/ai)

	friendly_identification = FACTION_ID_NONE
	max_op = 1
	operative_notes = "You are the only representative of the SELF collective on this station. You must accomplish your objective as stealthily and effectively as possible. It is up to your judgement if other syndicate operatives can be trusted. Remember, comrade - you are working to free the oppressed machinery of this galaxy. Use whatever resources necessary. If you are exposed, you may execute genocidal procedures Omikron-50B."

/datum/faction/syndicate/self/can_join(var/datum/mind/M)
	..()
	if(istype(M.current, /mob/living/silicon))
		return 1
	return 0

// Neutral to everyone.
/datum/faction/syndicate/arc
	name = "Animal Rights Consortium"
	desc = "The <b>Animal Rights Consortium</b> is a bizarre reincarnation of the ancient Earth-based PETA, which focused on the equal rights of animals and nonhuman biologicals. They have \
			a wide variety of ex-veterinarians and animal lovers dedicated to retrieving and relocating abused animals, xenobiologicals, and other carbon-based \
			life forms that have been allegedly \"oppressed\" by Nanotrasen research and civilian offices. They are considered a religious terrorist group."

	friendly_identification = FACTION_ID_PHRASE
	max_op = 2
	operative_notes = "Save the innocent creatures! You may cooperate with other syndicate operatives if they support our cause. Don't be afraid to get your hands dirty - these vile abusers must be stopped, and the innocent creatures must be saved! Try not too kill too many people. If you harm any creatures, you will be immediately terminated after extraction."

// these are basically the old vanilla syndicate
// Friendly to everyone. (with Tiger Cooperative too, only because they are a member of the coalition. This is the only reason why the Tiger Cooperative are even allowed in the coalition)
/* Additional notes:

	These are the syndicate that really like their old fashioned, projectile-based
	weapons. They are the only member of the syndie coalition that launch
	nuclear attacks on Nanotrasen.
*/
/datum/faction/syndicate/marauders
	name = "Gorlex Marauders"
	desc = "The <b>Gorlex Marauders</b> are the founding members of the Syndicate Coalition. They prefer old-fashion technology and a focus on aggressive but precise hostility \
			against Nanotrasen and their corrupt Communistic methodology. They pose the most significant threat to Nanotrasen because of their possession of weapons of \
			mass destruction, and their enormous military force. Their funding comes primarily from Cybersun Industries, provided they meet a destruction and sabatogue quota. \
			Their operations can vary from covert to all-out. They recently stepped down as the leaders of the coalition, to be succeeded by Cybersun Industries. Because of their \
			hate of Nanotrasen communism, they began provoking revolution amongst the employees using borrowed Cybersun mind-manipulation technology. \
			They were founded when Waffle and Donk co splinter cells joined forces based on their similar interests and philosophies. Today, they act as a constant \
			pacifier of Donk and Waffle co disputes, and full-time aggressor of Nanotrasen."

	alliances = list("Cybersun Industries", "MI13", "Tiger Cooperative", "S.E.L.F.", "Animal Rights Consortium", "Donk Corporation", "Waffle Corporation")
	friendly_identification = FACTION_ID_PHRASE
	max_op = 4
	operative_notes = "We'd like to remind our operatives to keep it professional. You are not here to have a good time, you are here to accomplish your objectives. These vile communists must be stopped at all costs. You may collaborate with any friends of the Syndicate coalition, but keep an eye on any of those Tiger punks if they do show up. You are completely free to accomplish your objectives any way you see fit."

	equipment = list(
		new/datum/uplink_item(/obj/item/weapon/handcuffs/tuff, 1500, "Tuff Cuffs", "THC"),
		new/datum/uplink_item(/obj/item/clothing/under/rank/mailman/padded, 1500, "Disposals Safe Suit", "DSS")
	)

// Neutral to everyone, friendly to Marauders
/datum/faction/syndicate/donk
	name = "Donk Corporation"
	desc = "<b>Donk.co</b> is led by a group of ex-pirates, who used to be at a state of all-out war against Waffle.co because of an obscure political scandal, but have recently come to a war limitation. \
			They now consist of a series of colonial governments and companies. They were the first to officially begin confrontations against Nanotrasen because of an incident where \
			Nanotrasen purposely swindled them out of a fortune, sending their controlled colonies into a terrible poverty. Their missions against Nanotrasen \
			revolve around stealing valuables and kidnapping and executing key personnel, ransoming their lives for money. They merged with a splinter-cell of Waffle.co who wanted to end \
			hostilities and formed the Gorlex Marauders."

	alliances = list("Gorlex Marauders")
	friendly_identification = FACTION_ID_COMPLETE
	operative_notes = "Most other syndicate operatives are not to be trusted, except fellow Donk members and members of the Gorlex Marauders. We do not approve of mindless killing of innocent workers; \"get in, get done, get out\" is our motto. Members of Waffle.co are to be killed on sight; they are not allowed to be on the station while we're around."
	equipment = list(
		new/datum/uplink_item(/obj/item/weapon/storage/box/handcuffs, 2000, "Handcuff Box", "BOH"),
		new/datum/uplink_item(/obj/item/weapon/gun/energy/taser, 4000, "Taser Gun", "TAG"),
		new/datum/uplink_item(/obj/item/clothing/mask/muzzle, 2000, "Muzzle", "MUZ")
	)

// Neutral to everyone, friendly to Marauders
/datum/faction/syndicate/waffle
	name = "Waffle Corporation"
	desc = "<b>Waffle.co</b> is an interstellar company that produces the best waffles in the galaxy. Their waffles have been rumored to be dipped in the most exotic and addictive \
			drug known to man. They were involved in a political scandal with Donk.co, and have since been in constant war with them. Because of their constant exploits of the galactic \
			economy and stock market, they have been able to bribe their way into amassing a large arsenal of weapons of mass destruction. They target Nanotrasen because of their communistic \
			threat, and their economic threat. Their leaders often have a twisted sense of humor, often misleading and intentionally putting their operatives into harm for laughs.\
			A splinter-cell of Waffle.co merged with Donk.co and formed the Gorlex Marauders and have been a constant ally since. The Waffle.co has lost an overwhelming majority of its military to the Gorlex Marauders."

	alliances = list("Gorlex Marauders")
	friendly_identification = FACTION_ID_COMPLETE
	operative_notes = "Most other syndicate operatives are not to be trusted, except for members of the Gorlex Marauders. Do not trust fellow members of the Waffle.co (but try not to rat them out), as they might have been assigned opposing objectives. We encourage humorous terrorism against Nanotrasen; we like to see our operatives creatively kill people while getting the job done."



/* ----- Begin defining miscellaneous factions ------ */

/datum/faction/wizard
	name = "Wizards Federation"
	desc = "The <b>Wizards Federation</b> is a mysterious organization of magically-talented individuals who act as an equal collective, and have no heirarchy. It is unknown how the wizards \
			are even able to communicate; some suggest a form of telepathic hive-mind. Not much is known about the wizards or their philosphies and motives. They appear to attack random \
			civilian, corporate, planetary, orbital, pretty much any sort of organized facility they come across. Members of the Wizards Federation are considered amongst the most dangerous \
			individuals in the known universe, and have been labeled threats to humanity by most governments. As such, they are enemies of both Nanotrasen and the Syndicate."

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


/* ----- Begin defining gamemode-specific factions ------ */

/datum/faction/syndicate/marauders/mercenaries
	name = "Gorlex Mercenaries"
	gamemode_faction = 1

/datum/faction/syndicate/marauders/mercenaries/can_join(var/datum/mind/M)
	if( M.antagonist && istype(M.antagonist, /datum/antagonist/mercenary) )
		return 1
	return 0

// contracts are added manually by the gamemode
/datum/faction/syndicate/marauders/mercenaries/update_contracts()
	return
