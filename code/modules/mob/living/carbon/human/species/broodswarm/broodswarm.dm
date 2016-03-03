/mob/living/carbon/human/broodmother/New(var/new_loc)
	..(new_loc, "Broodmother")
	character.hair_style = "Bald"

/mob/living/carbon/human/broodmother/death(gibbed)
	..()

	var/datum/species/broodswarm/broodmother/M = src.species

	if( M )
		var/turf/T

		if( !ticker.mode.hive )
			src << "<span class='warning'>Since the hive tumor was never placed, we are regenerating somewhere random...</span>"
			T = pick( xeno_spawn )
		else
			src << "<span class='notice'>We have been defeated, but we will return stronger...</span>"
			T = ticker.mode.hive.controller.pickOpenBlotch() // Returns an open space of blotch

		M.nodule( src, T )
