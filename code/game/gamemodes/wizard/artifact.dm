// Veil render //

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = 3
	var/charged = 1

/obj/effect/custom_portal
	name = "Tear in the fabric of reality"
	desc = "It looks pretty radical on the other side!"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/x_target
	var/y_target
	var/z_target

/obj/effect/custom_portal/Crossed(var/mob/A)
	if(istype(A, /mob/living/silicon))		return		//no silicons!
	if(x_target && y_target && z_target)
		A.x = x_target
		A.y = y_target
		A.z = z_target
		A << "<span class='danger'>You jump through the portal and end up in some unknown place! Oh god how will you get back?</span>"
	else
		A << "<span class='warning'>You can't seem to go through the portal! It is like a wall!</span>"

/obj/effect/custom_portal/Crossed(var/obj/O)
	if(istype(O, /obj/mecha))		return			//no mechs!
	if(x_target && y_target && z_target)
		O.x = x_target
		O.y = y_target
		O.z = z_target

/obj/effect/rend
	name = "Tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0


/obj/effect/rend/New()
	spawn(50)
		new /obj/singularity/narsie/wizard(get_turf(src))
		qdel(src)
		return
	return


/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged == 1)
		new /obj/effect/rend(get_turf(usr))
		charged = 0
		visible_message("<span class='alert'><B>[src] hums with power as [usr] deals a blow to reality itself!</B></span>")
	else
		user << "<span class='alert'>The unearthly energies that powered the blade are now dormant</span>"

// Scrying orb //

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 10
	damtype = BURN
	force = 10
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "<span class='info'>You can see... everything!</span>"
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
	announce_ghost_joinleave(user.ghostize(1), 1, "You feel that they used a powerful artifact to [pick("invade","disturb","disrupt","infest","taint","spoil","blight")] this place with their presence.")
	return
