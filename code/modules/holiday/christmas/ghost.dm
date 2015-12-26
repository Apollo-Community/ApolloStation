//Direct Rip of Halloween boss - Up for change

/mob/living/simple_animal/holiday_spirit
	name = "Holiday Spirit"
	icon = 'icons/mob/spirit.dmi'
	icon_state = "holiday"
	icon_living = "holiday"
	icon_dead = ""
	maxHealth = 300	// all those milk and cookies really raise your stats
	health = 300
	var/list/questions = list(  "What do you call a cat sitting on the beach on Christmas Eve?" = "sandy claws",
								"What do you get when you cross a snowman with a vampire?" = "frostbite",
								"What do Santa’s elves drive?" = "minivans",
								"What breakfast cereal does Frosty the Snowman eat?" = "snowflakes",
								"What do you get if Santa comes down your chimney when the fire is lit?" = "crisp kringle",
								"What do you call an old snowman?" = "water" )

	var/question = ""
	var/question_asked = 0
	var/answered = 0

/mob/living/simple_animal/holiday_spirit/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "",var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if( !speaker )
		return

	if( !speaker.client )
		return

	if( !question_asked )
		return

	if( answered )
		return

	if( lowertext( message ) == questions[question] )
		answered = 1
		src.visible_message("<b>[src]</b> says, \"[speaker] got the right answer!\"" )
		if( log_acc_item_to_db( speaker.ckey, "Candy Cane" ))
			speaker << "<span class='notice'><b>Christmas Cheer - You've answered the spirit's question correctly! An item has been added to your account as a reward.</b></span>"
		else
			speaker << "<span class='notice'><b>Christmas Cheer - You've already collected this item. Sorry!</b></span>"

/mob/living/simple_animal/holiday_spirit/New()
	..()

	world << "<font size='22' color='red'><b>THE HOLIDAY SPIRIT HAS RISEN</b></font>"

/mob/living/simple_animal/holiday_spirit/attack_hand(mob/user as mob)
	question = pick( questions )
	answered = 0
	question_asked = 1

	src.visible_message("<b>[src]</b> says, \"[question]!\"" )

/mob/living/simple_animal/holiday_spirit/attackby()
	return

/mob/living/simple_animal/holiday_spirit/bullet_act()
	return

/mob/living/simple_animal/holiday_spirit/death()
	world << "<font size='22' color='red'><b>THE HOLIDAY SPIRIT HAS BEEN KILLED</b></font>"

	qdel( src )
