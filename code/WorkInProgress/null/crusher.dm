/obj/machinery/crusher
	name = "crusher"
	desc = "A compact machine with a spiked and serated rolling pin designed to shred and crush materials going through it into fine powder. \
			There is a large and well worn red button labeled 'emergency stop' on the side of the machine."
	icon = 'icons/obj/machines/refining.dmi'
	icon_state = "grinder0"
	layer = MOB_LAYER+0.1 //So it draws over mobs
	anchored = 1
	density = 1

	var/on = 0

	var/datum/chemicals/storage

/obj/machinery/crusher/New()
	..()
	storage = new(src, 250)
	update_icon()

/obj/machinery/crusher/Destroy()
	qdel(storage)
	..()

/obj/machinery/crusher/update_icon()
	icon_state = "grinder[on]"

/obj/machinery/crusher/Bumped(M as mob|obj)
	if(isnull(M))
		return
	if(stat || !storage || storage.volume >= storage.max_volume || !on)
		return
	if(istype(M, /obj))
		var/obj/O = M
		var/oldloc = O.loc
		if(get_dir(loc, oldloc) != dir)
			return
		O.loc = src.loc
		var/list/crush_result = O.crush_act(src)
		if(crush_result)
			storage.adjust_many(crush_result)
		if(O)
			spawn(10)
				O.loc = oldloc
		return

/obj/machinery/crusher/attack_hand(mob/user as mob)
	if(!istype(user, /mob/living/carbon/human))
		return
	src.add_fingerprint(user)
	on = !on
	user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
	user.changeNext_move(CLICK_CD_MELEE)
	update_icon()

/obj/machinery/crusher/process()
	..()

/obj/machinery/crusher/access_chems()
	return storage