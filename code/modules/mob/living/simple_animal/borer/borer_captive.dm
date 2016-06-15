/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"
	universal_understand = 1

/mob/living/captive_brain/New()
	//remove all the verbs (we currently have rest and stuff like wtf?)
	verbs.Cut()

	verbs += /mob/living/captive_brain/verb/resist_borer

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='alert'>You cannot speak in IC (muted).</span>"
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))

		message = sanitize(message)
		if (!message)
			return
		log_say("[key_name(src)] : [message]")
		if (stat == 2)
			return say_dead(message)

		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "The captive mind of [src] whispers, \"[message]\""

		for (var/mob/M in player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				M << "The captive mind of [src] whispers, \"[message]\""

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/captive_brain/verb/resist_borer()
	set name = "Resist Borer"
	set category = "IC"
	set desc = "Resist the other worldy force inside your mind!"

	var/mob/living/simple_animal/borer/B = loc

	if(B && B.controlling)
		B << "<span class='warning'>The host begins to resist your presence!</span>"
		src << "<span class='warning'>You begin to fight the other worldly force inside your brain!</span>"
		spawn(rand(300,900))
			if(B.controlling)
				B << "<span class='alert'><B>You retract your probosci, releasing control of [B.host_brain]</B></span>"

				B.detatch()

				verbs -= /mob/living/carbon/proc/release_control
				verbs -= /mob/living/carbon/proc/punish_host
				verbs -= /mob/living/carbon/proc/spawn_larvae
