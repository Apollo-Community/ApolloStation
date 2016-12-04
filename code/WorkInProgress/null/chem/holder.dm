/datum/chemicals
	var/atom/holder // The atom this should inherit location data from, if any.
	var/list/contents = list() // The list of contents and their volumes. type:moles
	var/temperature = T20C // The temperature of the mixture.
	var/volume = 0	// The current volume of the mixture.
	var/max_volume = 0 // The volume of the container, if any. If there is no volume, pressure and volume equations cannot be used.

/datum/chemicals/New(atom/myatom, maxvol, temp)
	..()
	if(myatom)
		atom = myatom
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

