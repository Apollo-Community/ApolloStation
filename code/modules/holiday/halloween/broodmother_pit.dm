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
			//Woops forgot to reset it
			pumpkins.Cut()
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
	maxHealth = 250		//Since it does more damage - reduced health
	health = 250

/mob/living/simple_animal/hostile/alien/queen/halloween/attackby()
	//Attack back if you get attacked GAWD
	AttackingTarget()


/mob/living/simple_animal/hostile/alien/queen/halloween/death()
	for(var/mob/M in hearers(src,7))	// Should give anyone near broodmo the item
		M << "<span class='notice'><b>Halloween Secret - Congratulations! You've defeated the broodmother. The Bone Necklace has been added to your account as a reward.</b></span>"
		log_acc_item_to_db(M.ckey,/obj/item/clothing/mask/broodlace)

	..()

