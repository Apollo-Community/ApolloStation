// Short version of all antagonist workings:
// Faction controller > factions > contracts & antagonists
// Faction controller also hands out factions to antagonists
// contracts & antagonists reports back to factions. the faction controller just sets up factions and forces them to do shit

var/global/datum/controller/faction_controller/faction_controller

var/global/list/regular_contracts = list()
var/global/list/restricted_contracts = list()

/datum/controller/faction_controller
	var/list/datum/faction/factions = list()

/datum/controller/faction_controller/New()
	..()
	world << "faction_controller new()"
	faction_controller = src

/datum/controller/faction_controller/Destroy()
	..()
	for(var/datum/faction/F in factions)
		qdel(F)
		factions -= F

// setup a new faction from the subtypes of type, if possible
/datum/controller/faction_controller/proc/setup_faction(var/type=/datum/faction)
	var/datum/faction/F = null
	for(var/faction in subtypes(type))
		if(locate(faction) in factions)
			continue
		F = new faction()
		factions += F

	return F

// returns a syndicate faction with available slots and suitable criteria for the mob
/datum/controller/faction_controller/proc/get_syndie_faction(var/mob/living/M)
	var/list/datum/faction/syndicate/candidates = factions
	for(var/datum/faction/syndicate/S in candidates)
		if(!istype(S) || S.members.len >= S.max_op || (S.restricted_species.len > 0 && !(M.species.type in S.restricted_species)))	candidates -= S

	var/datum/faction/syndicate/F = null
	if(candidates.len == 0)
		F = setup_faction(/datum/faction/syndicate)
		candidates += F
	if(!F)	return 0 // no more factions to pick from

	while(F.restricted_species.len > 0 && !(M.species.type in F.restricted_species))
		F = setup_faction(/datum/faction/syndicate)
		if(!F)	return 0 // no more factions to pick from
		candidates += F

	// second cleanup. ensures that no species-restricted faction we can't join appears in candidates
	for(var/datum/faction/syndicate/S in candidates)
		if(!istype(S) || S.members.len >= S.max_op || (S.restricted_species.len > 0 && !(M.species.type in S.restricted_species)))	candidates -= S
	if(candidates.len == 0)	return 0 // no more factions to pick from, all available ones are species restricted

	return pick(candidates)

// starts a contract update for all syndicate factions
/datum/controller/faction_controller/proc/update_contracts()
	for(var/datum/faction/syndicate/S in factions)
		if(istype(S))	S.update_contracts()