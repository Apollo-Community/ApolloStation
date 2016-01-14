/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	unacidable = 1//Can't destroy energy portals.
	var/failchance = 5
	var/obj/item/target = null
	var/creator = null
	anchored = 1.0

/obj/effect/portal/Bumped(mob/M as mob|obj)
	spawn(0)
		src.teleport(M)
		return
	return

/obj/effect/portal/Crossed(AM as mob|obj)
	spawn(0)
		src.teleport(AM)
		return
	return

/obj/effect/portal/attack_hand(mob/user as mob)
	spawn(0)
		src.teleport(user)
		return
	return

/obj/effect/portal/New()
	spawn(300)
		qdel(src)
		return
	return

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if (M.anchored&&istype(M, /obj/mecha))
		return
	if (icon_state == "portal1")
		return
	if (!( target ))
		qdel(src)
		return
	if(src.loc.type == /turf/space/bluespace)
		if(ishuman(M))		// Harm humans for being silly.
			var/mob/living/carbon/human/H = M
			if(prob(80))
				usr << "<span class='warning'>As you touch the portal a violent shock rushes through your arm!</span>"
				var/datum/organ/external/E = H.get_organ(pick("l_arm","r_arm"))
				E.take_damage(15, 10, 5)
				E.fracture()
			/*else					Apprently TK is bugged :(
				usr << "<span class='info'>You feel the power of the portal enter your body!</span>"
				H.active_genes |= /datum/dna/gene/basic/tk
				H.update_icon = 1
			*/
		qdel(src)
		return
	if (istype(M, /atom/movable))
		if(prob(failchance)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			do_teleport_rand( M )
		else
			do_teleport( M, target ) ///You will appear adjacent to the beacon
