//placeholder for holiday stuff

//Apollo Easter 2015 Stuff

/obj/item/weapon/easter_egg
	icon = 'icons/apollo/objects.dmi'
	w_class = 2.0
	desc = "A colourful easter egg! Maybe it has chocolate inside?"

/obj/item/weapon/easter_egg/attack_self()
	open_egg()

/obj/item/weapon/easter_egg/verb/open_egg()
	set name = "Open Easter Egg"
	set category = "Object"
	set src in oview(1)

	if(!iscarbon(usr))
		return

	if(!fexists("sound/easter/[icon_state].ogg"))
		return

	var/sound/AL = sound("sound/easter/[icon_state].ogg", repeat = 0, wait = 1, channel = 777, volume = 35)
	AL.priority = 250

	log_admin("[key_name(usr)] is listening to [icon_state].ogg")
	message_admins("[key_name(usr)] is listening to [icon_state].ogg", 1)

	usr << AL

/obj/item/weapon/easter_egg/stuicey
	icon_state = "stuicey"
	name = "Stuicey's Egg"

/obj/item/weapon/easter_egg/kwask
	icon_state = "Kwask"
	name = "Kwask's Egg"

/obj/item/weapon/easter_egg/dragarien
	icon_state = "dragarien"
	name = "Dragarien's Egg"

/obj/item/weapon/easter_egg/Donnern
	icon_state = "donnern"
	name = "Donnern's Egg"

/obj/item/weapon/easter_egg/kingnexus
	icon_state = "kingnexus"
	name = "King Nexus's Egg"

/obj/item/weapon/easter_egg/jmmj
	icon_state = "jmmj"
	name = "JMMJ's Egg"