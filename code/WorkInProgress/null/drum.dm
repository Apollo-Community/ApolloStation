/obj/structure/drum
	name = "metal drum"
	desc = "a large metal drum used for storing liquids."
	var/volume = 2000


/obj/structure/drum/New()
	..()
	if(volume)
		desc += "It can hold [volume] units."

/obj/structure/drum/Destroy()
	..()

/obj/structure/drum/proc/fillup(list/chems, )