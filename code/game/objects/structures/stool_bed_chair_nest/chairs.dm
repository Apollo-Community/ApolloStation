/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair1"

	var/propelled = 0 // Check for fire-extinguisher-driven chairs

/obj/structure/bed/chair/New()
	..()
	spawn(3)	//sorry. i don't think there's a better way to do this.
		update_layer()
	return

/obj/structure/bed/chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype(W, /obj/item/weapon/wrench/) )
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src.loc)
		if(istype(src, /obj/structure/bed/chair/office/)) M.amount = 5
		else if(istype(src, /obj/structure/bed/chair/comfy/)) M.amount = 2
		else M.amount = 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		qdel(src)
		return
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			user << "<span class='notice'>[SK] is not ready to be attached!</span>"
			return
		user.drop_item()
		var/obj/structure/bed/chair/e_chair/E = new /obj/structure/bed/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.set_dir(dir)
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)
	..()

/obj/structure/bed/chair/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/bed/chair/proc/update_layer()
	if(src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER

/obj/structure/bed/chair/set_dir()
	..()
	update_layer()
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		src.set_dir(turn(src.dir, 90))
		return
	else
		if(istype(usr,/mob/living/simple_animal/rodent))
			return
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.restrained())
			return

		src.set_dir(turn(src.dir, 90))
		return

/obj/structure/bed/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	buckle_mob(M, user)
	return

// Chair types
/obj/structure/bed/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/wood(src.loc)
		qdel(src)
	else
		..()

/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	var/image/armrest = null

/obj/structure/bed/chair/comfy/New()
	armrest = image("icons/obj/furniture.dmi", "comfychair_armrest")
	armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/bed/chair/comfy/afterbuckle()
	if(buckled_mob)
		overlays += armrest
	else
		overlays -= armrest

/obj/structure/bed/chair/comfy/brown
	color = rgb(141,70,0)

/obj/structure/bed/chair/comfy/red
	color = rgb(218,2,10)

/obj/structure/bed/chair/comfy/teal
	color = rgb(0,234,250)

/obj/structure/bed/chair/comfy/black
	color = rgb(60,60,60)

/obj/structure/bed/chair/comfy/green
	color = rgb(1,196,8)

/obj/structure/bed/chair/comfy/purp
	color = rgb(112,2,176)

/obj/structure/bed/chair/comfy/blue
	color = rgb(2,9,210)

/obj/structure/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/bed/chair/office
	anchored = 0
	movable = 1

/obj/structure/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/bed/chair/office/Move()
	..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		occupant.buckled = null
		occupant.Move(src.loc)
		occupant.buckled = src
		if (occupant && (src.loc != occupant.loc))
			if (propelled)
				for (var/mob/O in src.loc)
					if (O != occupant)
						Bump(O)
			else
				unbuckle()

/obj/structure/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob)	return

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle()

		var/def_zone = ran_zone()
		var/blocked = occupant.run_armor_check(def_zone, "melee")
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone, blocked)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.run_armor_check(def_zone, "melee")
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone, blocked)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/bed/chair/old
	name = "chair"
	desc = "It looks ugly."
	icon_state = "chair"

/obj/structure/bed/chair/cushion
	name = "chair"
	desc = "You sit in this. This one has a cushioned seat."
	icon_state = "chair2"

/obj/structure/bed/chair/shuttle
	name = "shuttle chair"
	desc = "It looks uncomfortable."
	icon_state = "chair3"
	var/image/armrest = null

/obj/structure/bed/chair/shuttle/New()
	armrest = image("icons/obj/furniture.dmi", "chair3_overlay")
	armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/bed/chair/shuttle/afterbuckle()
	if(buckled_mob)
		overlays += armrest
	else
		overlays -= armrest
