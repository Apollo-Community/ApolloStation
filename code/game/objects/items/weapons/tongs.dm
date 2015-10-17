/obj/item/weapon/tongs
	name = "tongs"
	desc = "Tungsten-alloy tongs used for handling dangerous materials."
	force = 7.0
	throwforce = 12.0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "tongs"
	edge = 1
	w_class = 2
	flags = CONDUCT
	var/obj/item/held = null // The item currently being held

/obj/item/weapon/tongs/proc/pick_up( var/obj/item/I )
	if(held) return
	held = I
	I.loc = src
	playsound(loc, 'sound/effects/tong_pickup.ogg', 50, 1, -1)

/obj/item/weapon/tongs/attack_self(var/mob/user as mob)
	if( held )
		var/turf/T = get_turf(user.loc)
		held.loc = T
		held = null
		icon_state = initial(icon_state)
	..()

/obj/item/weapon/tongs/update_icon()
	if( !held )
		icon_state = initial( icon_state )
	else if( istype( held, /obj/item/weapon/shard/supermatter ))
		icon_state = "tongs_supermatter"
