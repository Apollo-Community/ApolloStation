/mob/living/simple_animal/dog
	name = "dog"
	desc = "Hello, I am dog."

	speak = list("Woof!", "Bark!")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5
	mob_size = 8

	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger


/mob/living/simple_animal/dog/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			for(var/mob/M in viewers(user, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\blue [user] baps [name] on the nose with the rolled up [O]")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					sleep(1)
	else
		..()
