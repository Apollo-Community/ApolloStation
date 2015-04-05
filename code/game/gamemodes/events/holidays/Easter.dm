//placeholder for holiday stuff

//Apollo Easter 2015 Stuff

/hook/startup/proc/load_eggs()
	for(var/E in list("Stuicey","Kwask","Dragarien","Donnern","JMMJ01","King_Nexus"))
		var/obj/D = new /obj/item/weapon/easter_egg(pick(blobstart))
		D.icon_state = E
		D.name = "easter egg"

/obj/item/weapon/easter_egg
	icon = 'icons/apollo/easter.dmi'
	w_class = 2.0
	desc = "A colourful easter egg! Maybe it has chocolate inside?"
	var/listening = 0

/obj/item/weapon/easter_egg/attack_self()
	open_egg()

/obj/item/weapon/easter_egg/verb/open_egg()
	set name = "Open Easter Egg"
	set category = "Object"
	set src in oview(1)

	usr << "\blue You stroke the egg gently.."

	if(listening || !iscarbon(usr))
		usr << "\blue the egg does not respond.."
		return

	if(!fexists("sound/easter/[icon_state].ogg"))
		usr << "\red You slimey cheat! Go find the eggs on the <b>live</b> server!"
		return

	var/sound/AL = sound("sound/easter/[icon_state].ogg", repeat = 0, wait = 1, channel = 777, volume = 35)
	AL.priority = 250

	log_admin("[key_name(usr)] is listening to [icon_state].ogg")
	message_admins("[key_name(usr)] is listening to [icon_state].ogg", 1)
	usr << "\blue The egg vibrates for a brief moment and begins to play an audio log."

	usr << AL

	listening = 1
	spawn(300)
		listening = 0

	if(prob(25))
		new_egg(icon_state)
		usr << "\red The egg crumbles away..."
		del(src)

/obj/item/weapon/easter_egg/proc/new_egg(T as text)
	var/obj/D = new /obj/item/weapon/easter_egg(pick(blobstart))
	D.icon_state = T
	D.name = "[T]'s Egg"



