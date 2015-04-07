/obj/structure/sign/double/barsign
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	anchored = 1
	var/emagged = 0

	New()
		ChangeSign(pick("pinkflamingo", "magmasea", "limbo", "rustyaxe", "armokbar", "brokendrum", "meadbay", "thedamnwall", "thecavern", "cindikate", "theorchard", "thesaucyclown", "theclownshead", "whiskeyimplant", "carpecarp", "robustroadhouse", "greytide", "theredshirt", "slipperyshots", "honkednloaded", "thegreytide", ))
		return
	proc/ChangeSign(var/Text)
		src.icon_state = "[Text]"
		//on = 0
		//brightness_on = 4 //uncomment these when the lighting fixes get in
		return

/obj/structure/sign/double/barsign/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/id))
		if(!emagged)
			var/obj/item/weapon/card/id/card = I
			if(access_bar in card.GetAccess())
				var/sign_type = input(user, "What would you like to change the barsign to?") as null|anything in list("Off", "Pink Flamingo", "Magma Sea", "Limbo", "Rusty Axe", "Armok Bar", "Broken Drum", "Mead Bay", "The Damn Wall", "The Cavern", "Cindi Kate", "The Orchard", "The Saucy Clown", "The Clowns Head", "Whiskey Implant", "Carpe Carp", "Robust Roadhouse", "Greytide", "The Redshirt", "Slippery Shots","Honked n Loaded", "THE Greytide")
				if(sign_type == null)
					return
				else
					sign_type = replacetext(lowertext(sign_type), " ", "") // lowercase, strip spaces - along with choices for user options, avoids huge if-else-else
					src.ChangeSign(sign_type)
					user << "You change the barsign."
		else
			user << "The bar sign controls are fried."
	else if(istype(I, /obj/item/weapon/card/emag))
		emagged = 1

		user << "You hack the barsign!"

		playsound(src, pick( "sound/effects/evil_laugh_1.ogg", "sound/effects/evil_laugh_2.ogg", "sound/effects/evil_laugh_3.ogg" ), 70, 1)
		spawn( rand(100, 200))
			playsound(src, pick( "sound/effects/evil_laugh_1.ogg", "sound/effects/evil_laugh_2.ogg", "sound/effects/evil_laugh_3.ogg" ), 70, 1)
		spawn( rand(400, 600))
			playsound(src, pick( "sound/effects/evil_laugh_1.ogg", "sound/effects/evil_laugh_2.ogg", "sound/effects/evil_laugh_3.ogg" ), 70, 1)
		spawn( rand(600, 800))
			playsound(src, pick( "sound/effects/evil_laugh_1.ogg", "sound/effects/evil_laugh_2.ogg", "sound/effects/evil_laugh_3.ogg" ), 70, 1)
		spawn( rand(800, 1000))
			playsound(src, pick( "sound/effects/evil_laugh_1.ogg", "sound/effects/evil_laugh_2.ogg", "sound/effects/evil_laugh_3.ogg" ), 70, 1)

		src.ChangeSign("emag")


/obj/structure/sign/double/barsign/emp_act(severity)
	src.ChangeSign("emp")
	playsound(src, "sound/effects/EMPulse.ogg", 70, 1)

	emagged = 1