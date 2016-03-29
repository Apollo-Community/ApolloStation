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
	faction_controller = src

	setup_factions()

	for(var/path in subtypes(/datum/contract))
		var/datum/contract/C = new path()
		if(C.min_notoriety > 0)
			restricted_contracts += path
		else
			regular_contracts += path
		qdel(C)

/datum/controller/faction_controller/Destroy()
	..()
	for(var/datum/faction/F in factions)
		qdel(F)
		factions -= F

// create factions and add them to our list
/datum/controller/faction_controller/proc/setup_factions()
	var/datum/faction/F = null
	for(var/faction in (subtypes(/datum/faction) - /datum/faction/syndicate))
		if(locate(faction) in factions)
			continue
		F = new faction()
		factions += F

// returns a suitable syndicate faction for a mob
/datum/controller/faction_controller/proc/get_syndie_faction(var/mob/living/M)
	var/list/datum/faction/syndicate/candidates = factions
	for(var/datum/faction/syndicate/S in candidates)
		if(!istype(S) || S.members.len >= S.max_op || (S.restricted_species.len > 0 && !(M.species.type in S.restricted_species)))	candidates -= S

	if(candidates.len == 0)	return 0

	return pick(candidates)

// starts a contract update for all syndicate factions
/datum/controller/faction_controller/proc/update_contracts()
	for(var/datum/faction/syndicate/S in factions)
		if(istype(S))	S.update_contracts()