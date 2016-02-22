/mob/living/proc/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Abilities"

	if( !isConscious() )
		return

	handle_ventcrawl()

/mob/living/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Abilities"

	if( !isConscious() )
		return

	if (layer != 2.45)
		layer = 2.45 //Just above cables with their 2.44
		src << text("<span class='notice'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		src << text("<span class='notice'>You have stopped hiding.</span>")
