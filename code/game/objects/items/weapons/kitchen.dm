/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Trays
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	sharp = 0

	var/loaded      //Descriptive string for currently loaded food object.

/obj/item/weapon/kitchen/utensil/New()
	if (prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)
	return

/obj/item/weapon/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != I_HELP)
		if(user.zone_sel.selecting == "head" || user.zone_sel.selecting == "eyes")
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if (reagents.total_volume > 0)
		reagents.trans_to_ingest(M, reagents.total_volume)
		if(M == user)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='notice'>[] eats some [] from \the [].</span>", user, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='notice'>[] feeds [] some [] from \the []</span>", user, M, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		playsound(M.loc,'sound/items/eatfood.ogg', rand(10,40), 1)
		overlays.Cut()
		return
	else
		..()

/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"

/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/weapon/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/*
 * Knives
 */
/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0
	sharp = 1
	edge = 1
	hitsound = 'sound/weapons/knife.ogg'

	suicide_act(mob/user)
		viewers(user) << pick("<span class='alert'><b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='alert'><b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='alert'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='alert'>You accidentally cut yourself with the [src].</span>"
		user.take_organ_damage(20)
		return
	return ..()

/obj/item/weapon/kitchen/utensil/pknife
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 1
	throwforce = 1
	sharp = 0
	edge = 1 //for cutting pizzas

/obj/item/weapon/kitchen/utensil/pknife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='alert'>You somehow managed to cut yourself with the [src].</span>"
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchenknife
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	sharp = 1
	edge = 1
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	matter = list("metal" = 12000)
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/knife.ogg'

	suicide_act(mob/user)
		viewers(user) << pick("<span class='alert'><b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='alert'><b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='alert'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

//If it's a hatchet it goes here. I guess
/obj/item/weapon/kitchenknife/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")
	flags = CONDUCT
	force = 12.0
	w_class = 2.0
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	sharp = 1
	edge = 1
	matter = list("metal" = 15000)
	origin_tech = "materials=2;combat=1"

/*
 * Butcher's cleaver
 */
/obj/item/weapon/kitchenknife/butcher
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	matter = list("metal" = 12000)
	origin_tech = "materials=1"
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/butch/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='alert'>The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(2)
		return

	if(!in_unlogged(user))
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
		msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	var/t = user:zone_sel.selecting
	if (t == "head")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					H << "<span class='alert'>The helmet protects you from being hit hard in the head!</span>"
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				user.visible_message("<span class='alert'><B>[H] has been knocked unconscious!</B></span>", "<span class='alert'><B>You knock [H] unconscious!</B></span>")
				return
			else
				H.visible_message("<span class='alert'>[user] tried to knock [H] unconscious!</span>", "<span class='alert'>[user] tried to knock you unconscious!</span>")
				H.eye_blurry += 3
	return ..()

/* Trays  moved to /obj/item/weapon/storage/bag */