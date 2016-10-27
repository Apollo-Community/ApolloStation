/obj/vehicle/train/cargo/engine/jeni
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?
	on = 0
	powered = 1
	locked = 0
	load_item_visible = 1
	load_offset_x = 0
	mob_offset_y = 7
	active_engines = 1

/obj/item/weapon/key/jeni
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1

/obj/vehicle/train/cargo/engine/jeni/New()
	..()
	overlays.Cut()
	cell = new /obj/item/weapon/cell/high(src)
	key = new(src)
	turn_off()	//so engine verbs are correctly set
	create_reagents(240)
	update_layer()

/obj/vehicle/train/cargo/engine/jeni/examine(mob/user)
	user << "\icon[src] This [callme] contains [reagents.total_volume] unit\s of water!"
	if(mybag)
		user << "\A [mybag] is hanging on the [callme]."

/obj/vehicle/train/cargo/engine/jeni/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume > 1)
			reagents.trans_to(I, 2)
			user << "<span class='notice'>You wet [I] in the [callme].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			return
		else
			user << "<span class='notice'>This [callme] is out of water!</span>"
			return

	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the [callme].</span>"
		user.drop_item()
		I.loc = src
		mybag = I
		return
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/r = I
		user << "<span class='notice'>You transfer some liquid from the [I] into the [callme].</span>"
		I.reagents.trans_to(src, r.amount_per_transfer_from_this)
		return
	..()

/obj/vehicle/train/cargo/engine/jeni/Move()
	..()
	update_layer()
	update_mob()

/obj/vehicle/train/cargo/engine/jeni/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()

/obj/vehicle/train/cargo/engine/jeni/proc/update_layer()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

//Jeni cards cannot have anything latched to them!
/obj/vehicle/train/cargo/engine/jeni/latch(obj/vehicle/train/T, mob/user)
	return

/obj/vehicle/train/cargo/engine/jeni/load()
	..()
	update_mob()

/obj/vehicle/train/cargo/engine/jeni/proc/update_mob()
	if(usr)
		usr.set_dir(dir)
		switch(dir)
			if(SOUTH)
				usr.pixel_x = 0
				usr.pixel_y = 7
			if(WEST)
				usr.pixel_x = 13
				usr.pixel_y = 7
			if(NORTH)
				usr.pixel_x = 0
				usr.pixel_y = 4
			if(EAST)
				usr.pixel_x = -13
				usr.pixel_y = 7