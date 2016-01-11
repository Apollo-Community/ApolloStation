var/rat_king_spawned = 0 // I hate globals, but I cant think of a better way to do this

// Since there's no proc for the current object to check crossed objects
/mob/living/simple_animal/rodent/rat/Crossed( atom/movable/O )
	..()

	if( istype( O, /mob/living/simple_animal/rodent/rat/king ))
		var/mob/living/simple_animal/rodent/rat/king/K = O
		src.visible_message("<span class='warning'>[src] joins \the [K]</span>", \
							"<span class='notice'>We join our brethren in the kingdom. Long live the [K].<span>")
		K.absorb( src )

/*=======  LONG LIVE THE KING  =========*/
/mob/living/simple_animal/rodent/rat/king
	var/list/rats = list()

/mob/living/simple_animal/rodent/rat/king/New()
	..()
	rat_king_spawned = 1
	say_dead_direct( "The Rat King has risen, all rejoice and celebrate. The cooldown timer on rodent spawns has been removed." )

/mob/living/simple_animal/rodent/rat/king/death()
	say_dead_direct( "The Rat King has been slain, these are dark days. The cooldown timer on rodent spawns is active again." )
	rat_king_spawned = 0
	..()

/mob/living/simple_animal/rodent/rat/king/Move()
	..()

	for( var/mob/living/simple_animal/rodent/rat in rats )
		rat.dir = src.dir
		update_icon() // bad i know

/mob/living/simple_animal/rodent/rat/king/update_icon()
	..()

	src.overlays.Cut()

	if( rats.len < 3 && rats.len >= 1 )
		name = "Rat Baron"
	else if( rats.len <= 5 )
		name = "Rat Duke"
	else if( rats.len <= 10 )
		name = "Rat King"
	else if( rats.len <= 20 )
		name = "Rat Emporer"
	else if( rats.len <= 30 )
		name = "Rat Savior"
	else if( rats.len > 30 )
		name = "Rat God"

	real_name = name

	for( var/mob/living/simple_animal/rodent/R in rats )
		var/image/rat_overlay = image('icons/mob/animal.dmi', "[R.icon_state]")
		rat_overlay.dir = src.dir
		var/matrix/M = matrix()
		M.Translate(rand(-6, 6), rand(-4, 8))
		rat_overlay.transform = M
		src.overlays += rat_overlay

/mob/living/simple_animal/rodent/rat/king/proc/absorb( var/mob/living/simple_animal/rodent/R )
	if(!( R in rats ))
		R.Move( src )
		rats += R

	update_icon()

/mob/living/simple_animal/rodent/rat/king/proc/eject( var/mob/living/simple_animal/rodent/R )
	if( R in rats )
		R.Move( get_turf( src ))
		rats -= R

	update_icon()
