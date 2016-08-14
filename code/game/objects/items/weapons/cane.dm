/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	matter = list("metal" = 50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/cane/pois_cane
	desc = "An elegant black cane with a sharp needle protruding from the bottom."
	icon_state = "pcane"
	item_state = "pstick"
	force = 9.0
	edge = 1
	origin_tech = "illegal=3;combat=4"
	attack_verb = list("stabbed", "pierced", "jabbed", "thrusted")

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 25)
		..()
		return

	attack(mob/living/M as mob, mob/user as mob)
		if(!(istype(M,/mob)))
			return
		if(!in_unlogged(M))
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed (attempt) with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to poison [M.name] ([M.ckey])</font>")
			msg_admin_attack("[user.name] ([user.ckey]) Used the [src.name] to poison [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		..()

		if(M.can_inject(user,1))
			if(reagents.total_volume)
				if(M.reagents) reagents.trans_to(M, 5)
		return