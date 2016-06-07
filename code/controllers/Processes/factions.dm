// Short version of all antagonist workings:
// Faction controller > factions > contracts & antagonists (or members)
// Faction controller also hands out factions to antagonists
// contracts & antagonists reports back to factions. the faction controller just sets up factions and forces them to do shit

// You could say this is actually a contract master controller too?

var/global/datum/controller/process/faction_controller/faction_controller

var/global/list/regular_contracts = list()
var/global/list/restricted_contracts = list()

/datum/controller/process/faction_controller
	var/contract_delay = 12000 // this (in 1/10 seconds) is how long it takes before traitors get their contracts, and the factions are populated with contracts

	var/list/datum/faction/factions = list()
	var/contract_ban = 0 // stops any more contracts from being created

	var/contracts_made = 0

/datum/controller/process/faction_controller/setup()
	name = "faction controller"
	schedule_interval = 600 // every minute

/datum/controller/process/faction_controller/New()
	if( !faction_controller )
		faction_controller = src
	else
		qdel( src )
		return

	..()

	for(var/path in subtypes(/datum/contract))
		var/datum/contract/C = new path()
		if(findtext(C.title, "!BASE!"))	continue
		if(C.min_notoriety > 0)
			restricted_contracts += path
		else
			regular_contracts += path
		qdel(C)

	for(var/path in (subtypes(/datum/faction) - /datum/faction/syndicate))
		factions += new path()

/datum/controller/process/faction_controller/Destroy()
	..()
	for(var/datum/faction/F in factions)
		qdel(F)
		factions -= F

/datum/controller/process/faction_controller/doWork()
	if( ticker.mode == "extended" )
		return

	if( !contracts_made && world.time > ( ticker.game_start + contract_delay ))
		contracts_made = 1
		message_admins("[contract_delay/10] seconds have passed since game start. Contracts are now available to traitor antagonists.")

		update_contracts()

		for(var/datum/mind/M in ticker.minds)
			if( M.antagonist && istype( M.antagonist, /datum/antagonist/traitor ))
				M.current << "Contracts are now available from your uplink."

/datum/controller/process/faction_controller/proc/get_faction( var/name )
	for( var/datum/faction/F in factions )
		if( name == F.name )
			return F

// makes the mind join a faction. also works if a type is passed as the faction
/datum/controller/process/faction_controller/proc/join_faction(var/datum/mind/M, var/datum/faction/F)
	if(ispath(F))
		F = (locate(F) in factions)
	if(!F || ispath(F))	return 0

	F.join(M)

	return F

// removes the mind from the faction. also works if a type is passed as the faction
/datum/controller/process/faction_controller/proc/leave_faction(var/datum/mind/M, var/datum/faction/F)
	if(ispath(F))
		F = (locate(F) in factions)
	if(!F || ispath(F) || !(M in F.members))	return 0

	F.leave(M)

	return 1

// finds a suitable syndicate faction for a mind and joins it
/datum/controller/process/faction_controller/proc/get_syndie_faction(var/datum/mind/M)
	var/mob/living/mob = M.current
	if(!mob)	return 0

	var/list/datum/faction/syndicate/candidates = factions.Copy()
	for(var/datum/faction/F in candidates)
		if(!istype(F, /datum/faction/syndicate) || !F.can_join(M) )
			candidates -= F
			continue

	if(candidates.len == 0)	return 0

	return join_faction(M, pick(candidates))

// updates contracts for all syndicate factions
/datum/controller/process/faction_controller/proc/update_contracts()
	for(var/datum/faction/syndicate/S in factions)
		if(istype(S))	S.update_contracts()

// check completion for all contracts, then forcefully end them if nobody completed it
// only used at round end. using it anywhere else may fuck shit up bad
/datum/controller/process/faction_controller/proc/kill_contracts()
	contract_ban = 1

	for(var/datum/faction/syndicate/S in factions)
		for(var/datum/contract/C in S.contracts)
			C.check_completion()
			if(!C.finished)
				C.end()
