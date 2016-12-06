/datum/compound
	var/id = ""
	var/name = "Unknown Compound"
	var/volume = 10 // Volume in units, per mole. A realistic obfuscation layer to make 'good' chemistry needlessly more complicated. :)
	var/specific_heat = 20 // Amount of thermal energy required to raise 1 mole of this compound by 1 K

/datum/compound/proc/on_container_destroyed()
	return

// * Returns the actual volume of this compound, based on the molar amount. * //
/datum/compound/proc/settle_volume(datum/chemicals/holder)
	if(!istype(holder))
		return 0
	return holder.contents[src] * volume