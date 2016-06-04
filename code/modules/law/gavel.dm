/obj/item/weapon/gavel
	desc = "gavel"
	name = "gavel"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "gavel"
	slot_flags = SLOT_BELT
	force = 1
	throwforce = 2
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	attack_verb = list("justice'd", "guilty'd", "whacked", "whapped", "thumped", "thwacked")

/obj/item/weapon/gavel/suicide_act(mob/user)
	viewers(user) << "<span class='alert'><b>[user] is hitting \himself with the [src.name]! It looks like \he's trying to give \himself a summary execution!</b></span>"
	return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/gavel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	..()
	playsound(get_turf( src ), 'sound/items/gavel.ogg', 50, 1)

/obj/machinery/verdict_render
	name = "verdict render"
	desc = "Strike this to render a verdict in a trial."
	icon = 'icons/obj/objects.dmi'
	icon_state = "render"

	var/console_tag
	var/obj/machinery/computer/sentencing/console

/obj/machinery/verdict_render/New()
	..()

	spawn( 10 )
		if( console_tag )
			console = locate( console_tag )

/obj/machinery/verdict_render/attackby( obj/item/weapon/gavel/O as obj, user as mob)
	if( console && istype( O ))
		if( console.incident )
			console.render_verdict( user )
			playsound(get_turf( src ), 'sound/items/gavel.ogg', 50, 1)
		else
			user << "<span class='alert'>There is no active trial!</span>"
		return

	..()

/obj/machinery/verdict_render/courtroom
	console_tag = "sentencing_courtroom"
