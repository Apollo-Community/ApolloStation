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
		src.visible_message("<span class='warning'>[src] joins the [K.swarm_name] of \the [K]</span>", \
							"<span class='notice'>We join our brethren in \the [K.swarm_name]. Long live \the [K].<span>")
		K.absorb( src )

/*=======  LONG LIVE THE KING  =========*/
/mob/living/simple_animal/rodent/rat/king
	attacktext = "bitten"

	var/swarm_name = "peasentry"
	var/announce_name = "Request"
	var/list/rats = list()

/mob/living/simple_animal/rodent/rat/king/New()
	..()

	update()

	rat_king_spawned = 1
	say_dead_direct( "\The [src] has risen, all rejoice and celebrate. The cooldown timer on rodent spawns has been removed." )
	announceToRodents( "<span class='notice'>An heir to the rat throne has risen! Go at once and join his kingdom, long live the king!</span>" )

/mob/living/simple_animal/rodent/rat/king/death()
	announceToRodents( "<span class='notice'>\The [src] has been slain, these are dark days.</span>" )
	say_dead_direct( "\The [src] has been slain, these are dark days. The cooldown timer on rodent spawns is active again." )
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

	for( var/mob/living/simple_animal/rodent/R in rats )
		var/image/rat_overlay = image('icons/mob/animal.dmi', "[R.icon_state]")
		rat_overlay.dir = src.dir
		var/matrix/M = matrix()
		M.Translate(rand(-6, 6), rand(-4, 8))
		rat_overlay.transform = M
		src.overlays += rat_overlay

/mob/living/simple_animal/rodent/rat/king/bullet_act(var/obj/item/projectile/Proj)
	var/mob/living/simple_animal/rodent/R = getMobAttacked()
	R.bullet_act( Proj )
	ejectDeadRats()

/mob/living/simple_animal/rodent/rat/king/attack_hand(mob/living/carbon/human/M as mob)
	var/mob/living/simple_animal/rodent/R = getMobAttacked()
	R.attack_hand( M )
	ejectDeadRats()

/mob/living/simple_animal/rodent/rat/king/attackby(var/obj/item/O, var/mob/user)
	var/mob/living/simple_animal/rodent/R = getMobAttacked()
	R.attackby( O, user )
	ejectDeadRats()

/mob/living/simple_animal/rodent/rat/king/ex_act(severity)
	for( var/mob/living/simple_animal/rodent/R in rats )
		R.ex_act(severity)
		ejectDeadRats()

	..( severity )

/mob/living/simple_animal/rodent/rat/king/verb/update()
	if( rats.len >= RAT_GOD_LEVEL )
		name = "\improper Rat God"
		swarm_name = "creation"
		announce_name = "Word"
		desc = "A swarm of rats."
		attacktext = "swarmed"
		melee_damage_lower = 3
		melee_damage_upper = 10
	else if( rats.len >= RAT_SAVIOR_LEVEL )
		name = "\improper Rat Savior"
		swarm_name = "flock"
		announce_name = "Pronouncement"
		desc = "A swarm of rats."
		attacktext = "swarmed"
		melee_damage_lower = 2
		melee_damage_upper = 7
	else if( rats.len >= RAT_EMPORER_LEVEL )
		name = "\improper Rat Emporer"
		swarm_name = "empire"
		announce_name = "Command"
		desc = "A swarm of rats."
		attacktext = "swarmed"
		melee_damage_lower = 1
		melee_damage_upper = 5
	else if( rats.len >= RAT_KING_LEVEL )
		name = "\improper Rat King"
		swarm_name = "kingdom"
		announce_name = "Decree"
		desc = "A swarm of rats."
		attacktext = "swarmed"
		melee_damage_lower = 1
		melee_damage_upper = 3
	else if( rats.len >= RAT_DUKE_LEVEL )
		name = "\improper Rat Duke"
		swarm_name = "duchy"
		announce_name = "Decree"
		desc = "A swarm of rats."
		attacktext = "bitten"
	else if( rats.len >= RAT_BARON_LEVEL )
		name = "\improper Rat Baron"
		swarm_name = "barony"
		announce_name = "Decree"
		desc = "A swarm of rats."
		attacktext = "bitten"
	else if( rats.len >= RAT_MAYOR_LEVEL )
		name = "\improper Rat Mayor"
		swarm_name = "hamlet"
		announce_name = "Decree"
		desc = "A swarm of rats."
		attacktext = "bitten"
	else
		name = "\improper Rat Peasant"
		swarm_name = "peasentry"
		announce_name = "Request"
		desc = "A single rat. This one seems special."
		attacktext = "scratched"

	desc += " There are [rats.len] rats in his [swarm_name]."
	real_name = name

	if( canWalkFaster() )
		speed = -3
	else
		speed = 0

	ejectDeadRats( 0 )
	update_icon()

/mob/living/simple_animal/rodent/rat/king/verb/kingDecree()
	set category = "Abilities"
	set name = "Decree"

	var/input = sanitize(input(usr, "Please enter the [lowertext( announce_name )] for your whole kingdom.", "What?", "") as message|null, extra = 0)

	var/full_message = {"<hr><h2 class='alert'>[src]\'s [announce_name]</h2>
<span class='alert'>[input]</span><hr><br>"}

	announceToRodents( "[full_message]" )

/mob/living/simple_animal/rodent/rat/king/proc/getMobAttacked()
	if( rats.len )
		return rats[rats.len]
	return src

/mob/living/simple_animal/rodent/rat/king/proc/absorb( var/mob/living/simple_animal/rodent/R, var/update = 1 )
	if(!( R in rats ))
		R.Move( src )
		rats += R

	if( update )
		update()

/mob/living/simple_animal/rodent/rat/king/proc/eject( var/mob/living/simple_animal/rodent/R, var/update = 1 )
	if( R in rats )
		R.Move( get_turf( src ))
		rats -= R

	if( update )
		update()

/mob/living/simple_animal/rodent/rat/king/proc/kingdomMessage( var/message, var/king_message )
	for( var/R in rats )
		R << message

	if( king_message )
		src << king_message
	else
		src << message

/mob/living/simple_animal/rodent/rat/king/proc/ejectDeadRats( var/update = 1 )
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

	if( update )
		update()

/mob/living/simple_animal/rodent/rat/king/proc/getDeadRats()
	. = list()

	for( var/mob/living/simple_animal/rodent/R in rats )
		if( !R.health )
			. += R

	return .

/mob/living/simple_animal/rodent/rat/king/proc/canNibbleWire()
	if( rats.len >= RAT_MAYOR_LEVEL )
		return 1
	return 0

/*
/mob/living/simple_animal/rodent/rat/king/proc/
	if( rats.len >= RAT_BARON_LEVEL )
		return 1
	return 0
*/

/mob/living/simple_animal/rodent/rat/king/proc/canWalkFaster()
	if( rats.len >= RAT_DUKE_LEVEL )
		return 1
	return 0

/mob/living/simple_animal/rodent/rat/king/proc/canEatCorpse()
	if( rats.len >= RAT_KING_LEVEL )
		return 1
	return 0

/mob/living/simple_animal/rodent/rat/king/proc/canSmashGrille()
	if( rats.len >= RAT_EMPORER_LEVEL )
		return 1
	return 0

/mob/living/simple_animal/rodent/rat/king/proc/canSpreadDisease()
	if( rats.len >= RAT_SAVIOR_LEVEL )
		return 1
	return 0
