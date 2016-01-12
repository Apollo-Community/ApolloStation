#define RAT_MAYOR_LEVEL 1
#define RAT_BARON_LEVEL 3
#define RAT_DUKE_LEVEL 5
#define RAT_KING_LEVEL 10
#define RAT_EMPORER_LEVEL 20
#define RAT_SAVIOR_LEVEL 30
#define RAT_GOD_LEVEL 50

var/rat_king_spawned = 0 // I hate globals, but I cant think of a better way to do this

/proc/announceToRodents( var/message )
	for( var/R in world_rodents )
		R << message

// Since there's no proc for the current object to check crossed objects
/mob/living/simple_animal/rodent/rat/Crossed( atom/movable/O )
	..()

	if( !health )
		return

	if( istype( O, /mob/living/simple_animal/rodent/rat/king ))
		var/mob/living/simple_animal/rodent/rat/king/K = O
		src.visible_message("<span class='warning'>[src] joins kingdom of \the [K]</span>", \
							"<span class='notice'>We join our brethren in the kingdom. Long live the [K].<span>")
		K.absorb( src )

/*=======  LONG LIVE THE KING  =========*/
/mob/living/simple_animal/rodent/rat/king
	var/list/rats = list()

/mob/living/simple_animal/rodent/rat/king/New()
	..()

	update_icon()

	rat_king_spawned = 1
	say_dead_direct( "The Rat King has risen, all rejoice and celebrate. The cooldown timer on rodent spawns has been removed." )
	announceToRodents( "<span class='notice'>The great and honorable Rat King has risen! Go at once and join his kingdom, long live the king!</span>" )

/mob/living/simple_animal/rodent/rat/king/death()
	announceToRodents( "<span class='notice'>The Rat King has been slain, these are dark days.</span>" )
	say_dead_direct( "The Rat King has been slain, these are dark days. The cooldown timer on rodent spawns is active again." )
	rat_king_spawned = 0
	..()

/mob/living/simple_animal/rodent/rat/king/Move()
	..()

	for( var/mob/living/simple_animal/rodent/rat in rats )
		rat.dir = src.dir

	for( var/image/I in overlays )
		I.dir = src.dir

/mob/living/simple_animal/rodent/rat/king/update_icon()
	..()

	src.overlays.Cut()

	if( rats.len >= RAT_GOD_LEVEL )
		name = "\improper Rat God"
	else if( rats.len >= RAT_SAVIOR_LEVEL )
		name = "\improper Rat Savior"
	else if( rats.len >= RAT_EMPORER_LEVEL )
		name = "\improper Rat Emporer"
	else if( rats.len >= RAT_KING_LEVEL )
		name = "\improper Rat King"
	else if( rats.len >= RAT_DUKE_LEVEL )
		name = "\improper Rat Duke"
	else if( rats.len >= RAT_BARON_LEVEL )
		name = "\improper Rat Baron"
	else if( rats.len >= RAT_MAYOR_LEVEL )
		name = "\improper Rat Mayor"
	else
		name = "\improper Rat Peasant"

	real_name = name

	for( var/mob/living/simple_animal/rodent/R in rats )
		var/image/rat_overlay = image('icons/mob/animal.dmi', "[R.icon_state]")
		rat_overlay.dir = src.dir
		var/matrix/M = matrix()
		M.Translate(rand(-6, 6), rand(-4, 8))
		rat_overlay.transform = M
		src.overlays += rat_overlay

/mob/living/simple_animal/rodent/rat/king/bullet_act(var/obj/item/projectile/Proj)
	if( rats.len )
		var/mob/living/simple_animal/rodent/R = rats[rats.len]
		R.bullet_act( Proj )
		ejectDeadRats()
	else
		..( Proj )

/mob/living/simple_animal/rodent/rat/king/attack_hand(mob/living/carbon/human/M as mob)
	if( rats.len )
		var/mob/living/simple_animal/rodent/R = rats[rats.len]
		R.attack_hand( M )
		ejectDeadRats()
	else
		..( M )

/mob/living/simple_animal/rodent/rat/king/attackby(var/obj/item/O, var/mob/user)
	if( rats.len )
		var/mob/living/simple_animal/rodent/R = rats[rats.len]
		R.attackby( O, user )
		ejectDeadRats()
	else
		..( O, user )

/mob/living/simple_animal/rodent/rat/king/ex_act(severity)
	for( var/mob/living/simple_animal/rodent/R in rats )
		R.ex_act(severity)
		ejectDeadRats()

	..( severity )

/mob/living/simple_animal/rodent/rat/king/verb/kingDecree()
	set category = "Abilities"
	set name = "Decree"

	var/input = sanitize(input(usr, "Please enter the decree for your whole kingdom.", "What?", "") as message|null, extra = 0)

	var/full_message = {"<hr><h2 class='alert'>Rat King Decree</h2>
<span class='alert'>[input]</span><hr><br>"}

	announceToRodents( "[full_message]" )

/mob/living/simple_animal/rodent/rat/king/proc/absorb( var/mob/living/simple_animal/rodent/R, var/icon_update = 1 )
	if(!( R in rats ))
		R.Move( src )
		rats += R

	if( icon_update )
		update_icon()

/mob/living/simple_animal/rodent/rat/king/proc/eject( var/mob/living/simple_animal/rodent/R, var/icon_update = 1 )
	if( R in rats )
		R.Move( get_turf( src ))
		rats -= R

	if( icon_update )
		update_icon()

/mob/living/simple_animal/rodent/rat/king/proc/kingdomMessage( var/message, var/king_message )
	for( var/R in rats )
		R << message

	if( king_message )
		src << king_message
	else
		src << message

/mob/living/simple_animal/rodent/rat/king/proc/ejectDeadRats()
	var/list/dead_rats = getDeadRats()
	var/list/death_messages = list( " has been sacrificed for the good of the realm.", \
									" was abruptly ended, but will not be forgotten.", \
									" dared not breathe one breath more, for the sake of the king.", \
									" joined the choir invisible, sheltering our king from wrath.", \
									" was unable to carry on further, despite pleas from our beloved king.", \
									" suffered a blow most terrible, but his glory will live on." )

	for( var/R in dead_rats )
		kingdomMessage( "[R][pick(death_messages)]" )
		eject( R, 0 )

	update_icon()

/mob/living/simple_animal/rodent/rat/king/proc/getDeadRats()
	. = list()

	for( var/mob/living/simple_animal/rodent/R in rats )
		if( !R.health )
			. += R

	return .

/mob/living/simple_animal/rodent/rat/king/proc/canSmashGrille()
	if( rats.len <= RAT_EMPORER_LEVEL )
		return 1
	return 0

/mob/living/simple_animal/rodent/rat/king/proc/canEatCorpse()
	if( rats.len <= RAT_KING_LEVEL )
		return 1
	return 0
