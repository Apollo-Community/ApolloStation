/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to correct those who don't know their place."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	throwforce = 5
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined","corrected","enslaved")
	hitsound = 'sound/weapons/whip.ogg'

	suicide_act(mob/user)
		viewers(user) << "<span class='alert'><b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b></span>"
		return (OXYLOSS)
