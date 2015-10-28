/obj/structure/broodswam/hive_pit/halloween
	var/list/pumpkins = list()

/obj/structure/broodswam/hive_pit/halloween/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/spec_pumpkin))
		user << "You throw the [W.name] into the pit!"
		if(pumpkins.len<6)
			if(pumpkins.Find(W.icon_state))
				user << "This jack-o-lantern has already been thrown in the pit! Find the others"
				return
			else
				pumpkins.Add(W.icon_state)
			user << "A [pumpkins.len < 4 ? "noise" : "groan"] echo's from the bottom of the pit!"
			user << "<span class='notice'><b>Halloween Secret - [pumpkins.len] out of 7 have been thrown in!</b></span>"
		else
			user << "The broodmother has surfaced!"
			user << "<span class='notice'><b>Halloween Secret - Defeat the broodmother to unlock your reward!</b></span>"

			new /mob/living/simple_animal/hostile/alien/queen/halloween(src.loc)
		qdel(W)
	else
		user << "You don't think whatever is down there will like that.."



// The boss mob is an alien queen with more health
/mob/living/simple_animal/hostile/alien/queen/halloween
	name = "Broodmother"
	icon = 'icons/mob/broodmother.dmi'
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_dead = "broodmother"
	move_to_delay = 3		//Gotta go fast
	maxHealth = 700			//Gotta be stronk
	health = 700

/mob/living/simple_animal/hostile/alien/queen/halloween/death()
	..()
	// Can hook up the item to here ~