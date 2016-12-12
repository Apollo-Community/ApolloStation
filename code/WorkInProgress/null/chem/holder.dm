// * Reference list for active chemicals, by their ID * //
var/global/list/chemical = chemical_meta_init()

// * To initialize chemical list * //
/proc/chemical_meta_init()
	. = new /list
	for(var/path in subtypesof(/datum/compound))
		var/datum/compound/C = new path()

		if(C.id)
			.[C.id] = C
		else
			qdel(C)

#define SETTLED 1
#define CAN_REACT 2
#define CAN_SPILL 4

/datum/chemicals
	var/atom/holder // The atom this should inherit location data from, if any.
	var/list/contents = list() // The list of contents and their volumes. type:moles
	var/temperature = T20C // The temperature of the mixture.
	var/volume = 0	// The current volume of the mixture.
	var/max_volume = 0 // The volume of the container, if any. If there is no volume, pressure and volume equations cannot be used.
	var/thermal_energy = 0 // The thermal energy of the container. Archived.
	var/flags = 0 // Boolean values.

/datum/chemicals/New(atom/myatom, maxvol, temp)
	..()
	if(myatom)
		holder = myatom
	if(maxvol)
		max_volume = maxvol
	if(temp)
		temperature = temp

/datum/chemicals/Destroy()
	for(var/datum/compound/C in contents)
		C.on_container_destroyed()
	contents = null
	qdel(src)
	..()

// * Adds or removes a chemical from the mixture. * //
/datum/chemicals/proc/adjust(datum/compound/chem, amount = 0, temp = T20C)
	if(!istype(chem) || amount == 0 || !temp)
		return

	// If this chemical is already present, adjust its volume. Otherwise set the volume directly ONLY if the amount is positive.
	if(contents[chem])
		var/delta_amount = max(amount, -contents[chem]) // Cannot remove more than what is available.
		contents[chem] += delta_amount
		adjust_thermal_energy(delta_amount * chem.specific_heat * temp, TRUE)
	else if(amount)
		contents[chem] = amount
		adjust_thermal_energy(amount * chem.specific_heat * temp, TRUE)

	// Remove the chemical from contents if its molar volume is less than or equal to zero.
	if(!contents[chem])
		contents -= chem

	if(flags & SETTLED)
		flags &= ~SETTLED

// * Adds or removes a list of chemicals from the mixture. * //
/datum/chemicals/proc/adjust_many(list/chems, temp = T20C)
	if(!chems || !temp)
		return
	for(var/L in chems)
		adjust(chemical[L], chems[L], temp)

// * Adjusts the thermal energy of a mixure. * //
/datum/chemicals/proc/adjust_thermal_energy(amount)
	if(amount == 0)
		return

	thermal_energy = max(thermal_energy + amount, 0)
	if(flags & SETTLED)
		flags &= ~SETTLED

// * Refreshes the chemicals data and deals with all the calculations and reactions. * //
/datum/chemicals/proc/settle()
	if(flags & SETTLED)
		return

	flags &= SETTLED

	temperature = thermal_energy / heat_capacity()

	volume = 0
	for(var/datum/compound/C in contents)
		volume += C.settle_volume(src)

	if(volume > max_volume && flags & CAN_SPILL)
		spill()

	if(flags & CAN_REACT)
		for(var/datum/compound/C in contents)
			for(var/datum/chem_reaction/R in reaction_list[C.id])
				if(R.try_react(src))
					flags &= ~SETTLED
				continue

// * Handles volume overflow * //
/datum/chemicals/proc/spill()
	if(!flags & CAN_SPILL)
		return

// * Measures the true heat capacity of the chemical mixture. * //
/datum/chemicals/proc/heat_capacity()
	. = 1
	for(var/datum/compound/C in contents)
		. += contents[C] * C.specific_heat


#undef SETTLED
#undef CAN_REACT
#undef CAN_SPILL