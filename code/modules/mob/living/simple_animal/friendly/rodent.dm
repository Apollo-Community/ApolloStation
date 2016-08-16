var/global/list/world_rodents = list()

/mob/living/simple_animal/rodent
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	var/icon_sleeping = "mouse_gray_sleep"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	pass_flags = PASSTABLE
	small = 1
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = 0
	var/body_color //brown, gray and white, leave blank for random
	layer = MOB_LAYER
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	universal_understand = 1
	mob_size = 1

/mob/living/simple_animal/rodent/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(client)
		return

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		update_icon()
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			update_icon()
			wander = 1
		else if(prob(5))
			audible_emote("snuffles.")

/mob/living/simple_animal/rodent/proc/update_icon()
	if(stat ==  UNCONSCIOUS )
		icon_state = icon_sleeping
	else if(stat == CONSCIOUS)
		icon_state = icon_living

/mob/living/simple_animal/rodent/New()
	..()

	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

	name = "[name] ([rand(1, 1000)])"
	if(!body_color)
		body_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"
	icon_sleeping = "mouse_[body_color]_sleep"
	desc = "It's a small [body_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

	world_rodents += src

/mob/living/simple_animal/rodent/ghostize()
	..()
	if(client)
		client.time_died_as_rodent = world.time

/mob/living/simple_animal/rodent/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[body_color]_splat"
	src.icon_state = "mouse_[body_color]_splat"
	layer = MOB_LAYER
	if(client)
		client.time_died_as_rodent = world.time

/mob/living/simple_animal/rodent/start_pulling(var/atom/movable/AM)//Prevents mouse from pulling things
	src << "<span class='warning'>You are too small to pull anything.</span>"
	return

/mob/living/simple_animal/rodent/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			M << "\blue \icon[src] Squeek!"
			M << 'sound/effects/mousesqueek.ogg'
	..()

/mob/living/simple_animal/rodent/death()
	layer = MOB_LAYER
	if(client)
		client.time_died_as_rodent = world.time

	world_rodents -= src

	..()

/mob/living/simple_animal/rodent/attackby(var/obj/item/O, var/mob/user)
	var/obj/item/stack/rods/R = O
	if(!istype(R))
		return ..(O, user)

	if(stat == DEAD)
		R.use(1)
		var/obj/item/weapon/reagent_containers/food/snacks/ratrod/raw/food = new()
		food.loc = get_turf(user)
		user.put_in_any_hand_if_possible(food)
		user << "<span class='warning'>You skewer \the [src] with a metal rod!</span>"
		qdel(src)

/*
 * Mouse types
 */

/mob/living/simple_animal/rodent/white
	body_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/rodent/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/rodent/brown
	body_color = "brown"
	icon_state = "mouse_brown"


//Cake's got too much money!!!!!
/mob/living/simple_animal/rodent/white/cake
	body_color = "cake"
	icon_state = "mouse_cake"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/rodent/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."

/mob/living/simple_animal/rodent/can_use_vents()
	return
