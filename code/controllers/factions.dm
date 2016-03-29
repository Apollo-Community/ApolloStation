// Short version of all antagonist workings:
// Faction controller > factions > contracts & antagonists (or members)
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

// makes the mind join a faction. also works if a type is passed as the faction
/datum/controller/faction_controller/proc/join_faction(var/datum/mind/M, var/datum/faction/F)
	if(ispath(F))
		F = (locate(F) in factions)
	if(!F)
		return 0
	F.members += M
	M.faction = F

	// set antagonist.faction if the mind is joining a syndicate faction
	if(istype(F, /datum/faction/syndicate) && M.antagonist)
		M.antagonist.faction = F

	return F

// removes the mind from the faction. also works if a type is passed as the faction
/datum/controller/faction_controller/proc/leave_faction(var/datum/mind/M, var/datum/faction/F)
	if(ispath(F))
		F = (locate(F) in factions)
	if(!F || !(M in F.members))	return 0
	F.members -= M
	M.faction = null

	if(istype(F, /datum/faction/syndicate) && M.antagonist)
		M.antagonist.faction = null

	return 1

// create factions and add them to our list
/datum/controller/faction_controller/proc/setup_factions()
	var/datum/faction/F = null
	for(var/faction in (subtypes(/datum/faction) - /datum/faction/syndicate))
		if(locate(faction) in factions)
			continue
		F = new faction()
		factions += F

// finds a suitable syndicate faction for a mind and joins it
/datum/controller/faction_controller/proc/get_syndie_faction(var/datum/mind/M)
	var/mob/living/mob = M.current
	if(!mob)	return 0

	var/datum/faction/syndicate/S = null
	var/list/datum/faction/syndicate/candidates = factions.Copy()
	for(var/datum/faction/F in candidates)
		if(!istype(F, /datum/faction/syndicate))
			candidates -= F
			continue
		S = F
		if((S.max_op > 0 && S.members.len >= S.max_op) || (S.restricted_species.len > 0 && !(mob.species.type in S.restricted_species)))
			candidates -= S

	if(candidates.len == 0)	return 0

	return join_faction(M, pick(candidates))

// updates contracts for all syndicate factions
/datum/controller/faction_controller/proc/update_contracts()
	for(var/datum/faction/syndicate/S in factions)
		if(istype(S))	S.update_contracts()
