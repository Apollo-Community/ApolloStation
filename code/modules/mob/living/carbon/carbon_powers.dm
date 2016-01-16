//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Abilities"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		src << "<span class='alert'> <B>You withdraw your probosci, releasing control of [B.host_brain]</B></span>"

		B.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/punish_host
		verbs -= /mob/living/carbon/proc/spawn_larvae

	else
		src << "<span class='alert'> <B>ERROR NO BORER OR BRAINMOB DETECTED IN THIS MOB, THIS IS A BUG !</B></span>"

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Abilities"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		src << "<span class='alert'> <B>You send a punishing spike of psychic agony lancing into your host's brain.</B></span>"

		if (species && (species.flags & NO_PAIN))
			B.host_brain << "<span class='alert'> You feel a strange sensation as a foreign influence prods your mind.</span>"
			src << "<span class='alert'> <B>It doesn't seem to be as effective as you hoped.</B></span>"
		else
			B.host_brain << "<span class='alert'> <B><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></B></span>"

/mob/living/carbon/proc/spawn_larvae()
	set category = "Abilities"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		src << "<span class='alert'> <B>Your host twitches and quivers as you rapidly excrete a larva from your sluglike body.</B></span>"
		visible_message("<span class='alert'> <B>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</B></span>")
		B.chemicals -= 100
		B.has_reproduced = 1

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src))

	else
		src << "You do not have enough chemicals stored to reproduce."
		return