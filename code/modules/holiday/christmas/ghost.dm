//Direct Rip of Halloween boss - Up for change

/mob/living/simple_animal/hostile/alien/queen/holiday
	name = "Ghost"
	icon = ''
	icon_state = "Ghost"
	icon_living = "Ghost"
	icon_dead = "Ghost_dead"
	maxHealth = 300		//Since it does more damage - reduced health
	health = 300

/mob/living/simple_animal/hostile/alien/queen/holiday/attackby()
	//Attack back if you get attacked GAWD
	AttackingTarget()

/mob/living/simple_animal/hostile/alien/queen/holiday/death()
	for(var/mob/living/M in orange(src,7))	// Should give anyone near the holiday item
		if( log_acc_item_to_db( M.ckey, "Candy Cane" ))
			M << "<span class='notice'><b>Christmas Cheer - Congratulations! You've defeated the Ghost. The Candy Cane Cane has been added to your account as a reward.</b></span>"
		else
			M << "<span class='notice'><b>Christmas Cheer - You've already collected this item. Sorry!</b></span>"

	qdel( src )
