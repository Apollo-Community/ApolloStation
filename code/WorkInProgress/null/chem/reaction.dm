var/global/list/reaction_list = reaction_list_init()

// * Builds list of reactions, and keys them by required reagent ids. * //
/proc/reaction_list_init()
	. = new /list
	for(var/path in subtypesof(/datum/chem_reaction))
		var/datum/chem_reaction/R = new path()
		for(var/C in R.reqs)
			.[C] += R

/datum/chem_reaction
	var/list/reqs = list() // List of required chemicals. This is the chemical that triggers the reaction.

/datum/chem_reaction/proc/try_react(datum/chemicals/holder)
	if(!istype(holder))
		return
