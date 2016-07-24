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
	density = 1			// set this to 0 when you've setup the portal
	unacidable = 1
	anchored = 1
	var/x_target = 129
	var/y_target = 184
	var/z_target = 3

	var/only_mob = 0

/obj/effect/custom_portal/Crossed(var/atom/movable/A)
	if(only_mob && !istype(A, /mob))		return
	if(istype(A, /mob/living/silicon) || istype(A, /obj/mecha))		return
	if(!x_target || !y_target || !z_target)		return

	A.loc = locate(x_target, y_target, z_target)

	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		C.alpha = 127

		C << "<span class='danger'>You jump through the portal and end up in some unknown place! Oh god how will you get back?</span>"

/obj/structure/dimensional_storage
	name = "Strange Microwave"
	desc = "Looks like something from one of those Japanese anime."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw-spook-off"
	var/linked_storage = null
	var/on = 0
	light_color = "#00e800"
	light_power = 3
	light_range = 3

/obj/structure/dimensional_storage/New()
	for(var/obj/structure/dimensional_storage/D in world)
		if(D == src)	continue
		D.linked_storage = src
		linked_storage = D
		break

/obj/structure/dimensional_storage/attackby(var/obj/W, var/mob/user)
	if(on)
		user << "<span class='danger'>The microwave is doing something! You probably shouldn't mess with it!"
		return
	user.visible_message("<span class='notice'>[user] puts the [W] into the [src]!</span>", "<b>You put the [W] into the [src]!</b>")
	user.drop_item()
	W.loc = src
	W.SpinAnimation()
	set_link(1)
	playsound(loc, 'sound/effects/neutron_charge.ogg', 50, 1, -1)
	spawn(rand(40,120))
		W.SpinAnimation(,0)
		W.loc = get_turf(linked_storage)
		set_link(0)
		playsound(loc, 'sound/machines/ding.ogg', 50, 1, -1)

/obj/structure/dimensional_storage/proc/set_link(var/state)
	if(linked_storage)
		var/obj/structure/dimensional_storage/D = linked_storage
		on = state
		D.on = state

		icon_state = "mw-spook[state ? "" : "-off"]"
		D.icon_state = "mw-spook[state ? "" : "-off"]"

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
